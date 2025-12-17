#include "DataLoaderBinary.h"
#include <QDebug>
#include <set>

DataLoaderBinary::DataLoaderBinary(const std::string& meta_path,
                                   const std::string& bin_path,
                                   const SingleViewerConfiguration& cfg)
    : cfg_(cfg)
{
    // Load metadata
    QFile metaFile(QString::fromStdString(meta_path));
    if (!metaFile.open(QIODevice::ReadOnly)) {
        qWarning() << "Failed to open meta file:" << QString::fromStdString(meta_path);
        assert(false);
    }
    QByteArray metaBytes = metaFile.readAll();
    metaFile.close();
    meta_json_ = json::parse(metaBytes.constData(), metaBytes.constData() + metaBytes.size());

    // Collect array metadata
    std::set<int> unique_frames; // store unique frame indices
    for (const auto& item : meta_json_["arrays"].items()) {
        const std::string& name = item.key();
        const auto& info = item.value();

        ArrayMeta meta;
        meta.dtype = info["dtype"];
        for (auto s : info["shape"])
            meta.shape.push_back(s);

        meta.offset = info["offset"];
        meta.nbytes = info["nbytes"];
        arrays_[name] = meta;

        // Extract frame index from array name
        size_t slash = name.find_last_of('/');
        int frame_idx = std::stoi(name.substr(slash + 1));
        unique_frames.insert(frame_idx); // insert ensures uniqueness
    }

    // Convert set to sorted vector
    frames_.assign(unique_frames.begin(), unique_frames.end());

    // Apply frame range if specified
    if (cfg_.NPZ_FRAME_RANGE.first >= 0) {
        frames_.erase(
            std::remove_if(frames_.begin(), frames_.end(),
                           [&](int f){ return f < cfg_.NPZ_FRAME_RANGE.first ||
                                               f > cfg_.NPZ_FRAME_RANGE.second; }),
            frames_.end());
    }

    num_frames_ = frames_.size();

    // Load binary
    QFile binFile(QString::fromStdString(bin_path));
    if (!binFile.open(QIODevice::ReadOnly)) {
        qWarning() << "Failed to open binary file:" << QString::fromStdString(bin_path);
        assert(false);
    }
    QByteArray binBytes = binFile.readAll();
    binFile.close();
    data_bin_.assign(binBytes.begin(), binBytes.end());

    preprocess_joints();
}


/* ------------ PUBLIC ------------ */

int DataLoaderBinary::get_frame_count () const {
    return num_frames_;
}

int DataLoaderBinary::get_fps () const {
    return cfg_.FPS;
}

MatrixXf DataLoaderBinary::get_joints(int frame_idx) const {
    return aligned_joints_.at(frame_idx);
    // if (cfg_.STATIC_ALIGN) {
    //     return aligned_joints_.at(frame_idx);
    // } else {
    //     std::string arr_name = "joints/" + std::to_string(frames_[frame_idx]);
    //     return read_array(arrays_.at(arr_name));
    // }
}

Vector3f DataLoaderBinary::get_root_velocity_sg(int frame_idx) const {
    if (frame_idx < 0 || frame_idx >= num_frames_)
        return Vector3f::Zero();
    return root_vel_[frame_idx];
}

Vector3f DataLoaderBinary::get_root_acceleration_sg(int frame_idx) const {
    if (frame_idx < 0 || frame_idx >= num_frames_)
        return Vector3f::Zero();
    return root_acc_[frame_idx];
}

const std::vector<std::pair<int,int>>& DataLoaderBinary::get_SMPL_edges() const {
    return cfg_.SMPL_EDGES;
}

/* ------------ PRIVATE ------------ */

void DataLoaderBinary::preprocess_joints() {
    root_vel_.assign(num_frames_, Vector3f::Zero());
    root_acc_.assign(num_frames_, Vector3f::Zero());

    // 1. Load joints + align / Z-up fix
    load_and_align_joints();

    // 2. Extract root positions
    std::vector<Vector3f> roots(num_frames_);
    extract_root_trajectory(roots);

    // 3. Smooth root trajectory with polynomial LSQ SG filter
    std::vector<Vector3f> smoothed(num_frames_);
    smooth_root_trajectory(roots, smoothed);

    // 4. Compute velocity & acceleration from smoothed positions
    compute_root_derivatives(smoothed);
}

QString eigenRowToQString(const Eigen::MatrixXf& m, int row)
{
    QString s = "("
                + QString::number(m(row,0)) + ", "
                + QString::number(m(row,1)) + ", "
                + QString::number(m(row,2)) + ")";
    return s;
}


void DataLoaderBinary::load_and_align_joints() {
    aligned_joints_.clear();
    aligned_joints_.resize(num_frames_);

    MatrixXf root_offset = MatrixXf::Zero(1, 3);
    bool root_set = false;

    for (int idx = 0; idx < num_frames_; ++idx) {
        int f = frames_[idx];
        std::string arr_name = "joints/" + std::to_string(f);

        MatrixXf joints = read_array(arrays_.at(arr_name));
        MatrixXf original_joints = joints;   // keep a copy for logging


        // align all coordinates to origin originally
        if (!root_set) {
            root_offset = joints.row(0);
            root_set = true;

            qDebug() << "[STATIC ALIGN] Root offset set to:" << eigenRowToQString(root_offset, 0);
        }
        joints.rowwise() -= root_offset.row(0);

        if (cfg_.STATIC_ALIGN) {
            MatrixXf frame_root = joints.row(0);
            joints.rowwise() -= frame_root.row(0);
        }

        if (!cfg_.Z_UP)
            joints = swap_yz(joints);

        // Log for first 5 frames
        // if (idx < 15 & idx % 5 == 0) {
        //     qDebug() << "\n--- Frame" << idx << "(source frame" << f << ") ---";
        //     qDebug() << "Root offset:" << eigenRowToQString(root_offset, 0);

        //     for (int j = 0; j < joints.rows(); ++j) {
        //         qDebug()
        //         << "Joint" << j << ": ("
        //         << original_joints(j,0) << ","
        //         << original_joints(j,1) << ","
        //         << original_joints(j,2) << ")  →  ("
        //         << joints(j,0) << ","
        //         << joints(j,1) << ","
        //         << joints(j,2) << ")";
        //     }
        // }

        aligned_joints_[idx] = joints;
    }
}

void DataLoaderBinary::extract_root_trajectory(std::vector<Vector3f>& roots) {
    for (int i = 0; i < num_frames_; i++) {
        roots[i] = aligned_joints_[i].row(0);  // root joint
    }
}

void DataLoaderBinary::smooth_root_trajectory(
    const std::vector<Vector3f>& roots,
    std::vector<Vector3f>& smoothed)
{
    const int half_window = 2;
    const int poly_order = 2;   // quadratic

    for (int i = 0; i < num_frames_; ++i) {

        int start = std::max(0, i - half_window);
        int end   = std::min(num_frames_ - 1, i + half_window);
        int count = end - start + 1;
        int local_idx = i - start;

        // Build time vector 0..count-1
        Eigen::VectorXf t(count);
        for (int k = 0; k < count; k++)
            t(k) = float(k);

        // Construct quadratic LSQ matrix A = [t^2, t, 1]
        Eigen::MatrixXf A(count, 3);
        for (int k = 0; k < count; k++) {
            A(k, 0) = t(k) * t(k);
            A(k, 1) = t(k);
            A(k, 2) = 1.0f;
        }

        // Fit per axis
        Vector3f result = Vector3f::Zero();

        for (int axis = 0; axis < 3; axis++) {
            Eigen::VectorXf y(count);
            for (int k = 0; k < count; k++)
                y(k) = roots[start + k](axis);

            // LSQ: minimize |A*c - y|
            Eigen::Vector3f coeff = A.colPivHouseholderQr().solve(y);

            float t_eval = float(local_idx);
            result(axis) =
                coeff(0) * t_eval * t_eval +
                coeff(1) * t_eval +
                coeff(2);
        }

        smoothed[i] = result;
    }
}

void DataLoaderBinary::compute_root_derivatives(
    const std::vector<Vector3f>& smoothed)
{
    float dt = 1.0f / cfg_.FPS;

    for (int i = 0; i < num_frames_; i++) {

        if (i > 0 && i < num_frames_ - 1) {

            const Vector3f& prev = smoothed[i - 1];
            const Vector3f& curr = smoothed[i];
            const Vector3f& next = smoothed[i + 1];

            // Central difference velocity
            root_vel_[i] = (next - prev) / (2.0f * dt);

            // Central second derivative acceleration
            root_acc_[i] = (next - 2.0f * curr + prev) / (dt * dt);

        } else {
            // Edge frames fallback
            root_vel_[i].setZero();
            root_acc_[i].setZero();
        }
    }
}

MatrixXf DataLoaderBinary::swap_yz(const MatrixXf& joints) const {
    MatrixXf out = joints;
    out.col(1) = joints.col(2);
    out.col(2) = joints.col(1);
    return out;
}

MatrixXf DataLoaderBinary::read_array(const ArrayMeta& meta) const {
    size_t n_elements = 1;
    for (auto s : meta.shape) n_elements *= s;
    assert(sizeof(float) * n_elements == meta.nbytes);

    const float* ptr = reinterpret_cast<const float*>(data_bin_.data() + meta.offset);
    MatrixXf mat(meta.shape[0], meta.shape[1]);

    for (int i = 0; i < meta.shape[0]; ++i)
        for (int j = 0; j < meta.shape[1]; ++j)
            mat(i,j) = ptr[i * meta.shape[1] + j];

    return mat;
}



