#pragma once
#include <string>
#include <vector>
#include <cstddef>

struct ArrayMeta {
    std::string dtype;
    std::vector<int> shape;
    size_t offset;
    size_t nbytes;
};
