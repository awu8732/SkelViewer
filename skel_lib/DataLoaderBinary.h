#pragma once

#include <vector>
#include <map>
#include <string>
#include <cassert>
#include <Eigen/Dense>
#include <nlohmann/json.hpp>
#include <QFile>
#include <QIODevice>
#include <QDebug>

#include "ArrayMeta.h"
#include "SingleViewerConfiguration.h"

using json = nlohmann::json;
using Eigen::MatrixXf;
using Eigen::Vector3f;

class DataLoaderBinary {
public:
    DataLoaderBinary(const std::string& meta_path,
                     const std::string& bin_path,
                     const SingleViewerConfiguration& cfg);

    int get_frame_count () const;
    int get_fps () const;
    MatrixXf get_joints(int frame_idx) const;
    Vector3f get_root_velocity_sg(int frame_idx) const;
    Vector3f get_root_acceleration_sg(int frame_idx) const;
    const std::vector<std::pair<int,int>>& get_SMPL_edges() const;

private:
    SingleViewerConfiguration cfg_;
    json meta_json_;
    std::vector<uint8_t> data_bin_;
    std::map<std::string, ArrayMeta> arrays_;
    std::vector<int> frames_;
    int num_frames_;
    std::vector<MatrixXf> aligned_joints_;
    std::vector<Vector3f> root_vel_;
    std::vector<Vector3f> root_acc_;

    void preprocess_joints();
    void load_and_align_joints();
    void extract_root_trajectory(std::vector<Vector3f>& roots);
    void smooth_root_trajectory(const std::vector<Vector3f>& roots,
                                std::vector<Vector3f>& smoothed);
    void compute_root_derivatives(const std::vector<Vector3f>& smoothed);
    MatrixXf swap_yz(const MatrixXf& joints) const;
    MatrixXf read_array(const ArrayMeta& meta) const;
};
