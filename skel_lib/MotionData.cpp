#include "MotionData.h"
#include "thirdparty/cnpy/cnpy.h"
#include <QDebug>
#include <set>

MotionData::MotionData(const std::string& meta_path,
                                   const std::string& bin_path,
                                   const SingleViewerConfiguration& cfg)
    : cfg_(cfg)
{
    // Load metadata
    type_ = "custom";
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

MotionData::MotionData(const std::string& npz_path,
                       const SingleViewerConfiguration& cfg)
    : cfg_(cfg)
{
    type_ = cfg.type;
    cnpy::npz_t npz = cnpy::npz_load(npz_path);

    // ---- joints ----
    auto& joints_np = npz.at("joints");
    const float* joints_ptr = joints_np.data<float>();

    // Expected shape: [T, J, 3]
    assert(joints_np.shape.size() == 3);
    int T = joints_np.shape[0];
    int J = joints_np.shape[1];

    num_frames_ = T;
    frames_.resize(T);
    for (int i = 0; i < T; ++i)
        frames_[i] = i;

    raw_joints_.resize(T);

    for (int t = 0; t < T; ++t) {
        MatrixXf frame(J, 3);
        const float* frame_ptr =
            joints_ptr + t * J * 3;

        for (int j = 0; j < J; ++j)
            for (int k = 0; k < 3; ++k)
                frame(j, k) = frame_ptr[j * 3 + k];

        raw_joints_[t] = frame;
    }

    // ---- vertices ----
    auto& verts_np = npz.at("vertices");
    assert(verts_np.shape.size() == 3);

    assert(verts_np.shape.size() == 3);
    T = verts_np.shape[0];
    int V = verts_np.shape[1];
    assert(V == 6890);

    const float* verts_ptr = verts_np.data<float>();

    raw_vertices_.resize(T);

    for (int t = 0; t < T; ++t) {
        MatrixXf frame(V, 3);
        const float* frame_ptr = verts_ptr + t * V * 3;

        for (int i = 0; i < V; ++i)
            for (int k = 0; k < 3; ++k)
                frame(i, k) = frame_ptr[i * 3 + k];

        raw_vertices_[t] = frame;
    }

    // ---- FPS ----
    if (npz.count("mocap_framerate")) {
        cfg_.FPS = *npz.at("mocap_framerate").data<int>();
    }

    preprocess_joints();
}

/* ------------ PUBLIC ------------ */

int MotionData::get_frame_count () const {
    return num_frames_;
}

int MotionData::get_fps () const {
    return cfg_.FPS;
}

MatrixXf MotionData::get_joints(int frame_idx) const {
    return aligned_joints_.at(frame_idx);
}

Vector3f MotionData::get_root_velocity_sg(int frame_idx) const {
    if (frame_idx < 0 || frame_idx >= num_frames_)
        return Vector3f::Zero();
    return root_vel_[frame_idx];
}

Vector3f MotionData::get_root_acceleration_sg(int frame_idx) const {
    if (frame_idx < 0 || frame_idx >= num_frames_)
        return Vector3f::Zero();
    return root_acc_[frame_idx];
}

const std::vector<std::pair<int,int>>& MotionData::get_SMPL_edges() const {
    if (type_ == "skel") return cfg_.SKEL_EDGES;
    else return cfg_.SMPL_EDGES;
}

MatrixXf MotionData::get_vertices(int frame_idx) const {
    return aligned_vertices_.at(frame_idx);
}

/* ------------ PRIVATE ------------ */

void MotionData::preprocess_joints() {
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

void MotionData::load_and_align_joints()
{
    Q_ASSERT(!raw_joints_.empty());

    aligned_joints_.resize(num_frames_);
    aligned_vertices_.resize(num_frames_);

    // Reference root = frame 0 root
    Eigen::RowVector3f reference_root = raw_joints_[0].row(0);

    qDebug() << "[STATIC ALIGN] Reference root:"
             << reference_root(0)
             << reference_root(1)
             << reference_root(2);

    for (int idx = 0; idx < num_frames_; ++idx) {

        // -------------------------------------------------
        // Joints
        // -------------------------------------------------
        MatrixXf joints = raw_joints_[idx];
        const Eigen::RowVector3f current_root = joints.row(0);
        // if (idx < 3) {
        //     qDebug() << "Frame" << idx;
        //     for (int r = 0; r < joints.rows(); ++r) {
        //         QString rowStr;
        //         for (int c = 0; c < joints.cols(); ++c) {
        //             rowStr += QString::number(joints(r, c), 'f', 3) + " ";
        //         }
        //         qDebug() << rowStr;
        //     }
        // }
        if (cfg_.GLOBAL_ALIGN) {
            // Lock skeleton in place
            joints.rowwise() -= current_root;
        }
        else {
            joints.rowwise() -= reference_root;
        }

        if (!cfg_.Z_UP) {
            joints = swap_yz(joints);
        }

        aligned_joints_[idx] = joints;

        // -------------------------------------------------
        // Vertices (SMPL or SKEL only)
        // -------------------------------------------------
        if (type_ == "smpl" || type_ == "skel") {

            MatrixXf verts = raw_vertices_[idx];
            const Eigen::RowVector3f current_root = raw_joints_[idx].row(0);

            if (cfg_.GLOBAL_ALIGN) {
                verts.rowwise() -= current_root;
            }
            else {
                verts.rowwise() -= reference_root;
            }

            if (!cfg_.Z_UP) {
                verts = swap_yz(verts);
            }

            aligned_vertices_[idx] = verts;
        }
    }
}


void MotionData::extract_root_trajectory(std::vector<Vector3f>& roots) {
    for (int i = 0; i < num_frames_; i++) {
        roots[i] = aligned_joints_[i].row(0);  // root joint
    }
}

void MotionData::smooth_root_trajectory(
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

void MotionData::compute_root_derivatives(
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

MatrixXf MotionData::swap_yz(const MatrixXf& joints) const {
    MatrixXf out = joints;
    out.col(1) = joints.col(2);
    out.col(2) = joints.col(1);
    return out;
}

MatrixXf MotionData::read_array(const ArrayMeta& meta) const {
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

