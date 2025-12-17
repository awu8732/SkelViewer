#pragma once
#include <utility>
#include <vector>

struct SingleViewerConfiguration {
    int FPS = 30;
    bool STATIC_ALIGN = false;
    bool Z_UP = true;
    std::pair<int,int> NPZ_FRAME_RANGE = {0,600}; // -1 = unused

    const std::vector<std::pair<int,int>> SMPL_EDGES = {
        {0, 1}, {1, 4}, {4, 7}, {7, 10},           // right leg
        {0, 2}, {2, 5}, {5, 8}, {8, 11},           // left leg
        {0, 3}, {3, 6}, {6, 9}, {9, 12}, {12, 15}, // spine-to-head
        {9, 14}, {14, 17}, {17, 19}, {19, 21},     // left arm
        {9, 13}, {13, 16}, {16, 18}, {18, 20},     // right arm
        {21, 23},    // left hand
        {20, 22}     // right hand
        // optional: {19, 23}, {22, 23}
    };
};
