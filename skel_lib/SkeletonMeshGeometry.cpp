#include "SkeletonMeshGeometry.h"
#include <QtQuick3D/QQuick3DGeometry>
#include <QFile>
#include <QTextStream>
#include <cstdint>

std::vector<uint32_t> loadSMPLFaces(const QString& filename);

SkeletonMeshGeometry::SkeletonMeshGeometry(QQuick3DObject* parent)
    : QQuick3DGeometry(parent)
{
    // --- Vertex attribute ---
    addAttribute(QQuick3DGeometry::Attribute::PositionSemantic,
                 0,
                 QQuick3DGeometry::Attribute::F32Type);

    // Index buffer (uint32)
    addAttribute(QQuick3DGeometry::Attribute::IndexSemantic,
                 0,
                 QQuick3DGeometry::Attribute::U32Type);

    addAttribute(QQuick3DGeometry::Attribute::NormalSemantic,
                 3 * sizeof(float),
                 QQuick3DGeometry::Attribute::F32Type);

    setStride(sizeof(float) * 6);
    initStaticIndexBuffer();
}

void SkeletonMeshGeometry::updateVertices(const QVector<QVector3D>& vertices)
{
    if (vertices.isEmpty())
        return;

    if (vertexCount_ != vertices.size()) {
        vertexCount_ = vertices.size();
        vertexBuffer_.resize(vertexCount_ * 6 * sizeof(float));
    }

    QVector<QVector3D> normals(vertexCount_, QVector3D(0,0,0));

    // Access faces (same data used for indexBuffer_)
    const uint32_t* faces = reinterpret_cast<const uint32_t*>(indexBuffer_.constData());
    int faceCount = indexBuffer_.size() / (3 * sizeof(uint32_t));

    // Compute face normals
    for (int f = 0; f < faceCount; ++f) {
        uint32_t i0 = faces[f*3 + 0];
        uint32_t i1 = faces[f*3 + 1];
        uint32_t i2 = faces[f*3 + 2];

        if (i0 >= vertexCount_ || i1 >= vertexCount_ || i2 >= vertexCount_) {
            qWarning() << "Invalid face index:" << i0 << i1 << i2
                       << "vertexCount =" << vertexCount_;
            continue;
        }

        QVector3D v0 = vertices[i0];
        QVector3D v1 = vertices[i1];
        QVector3D v2 = vertices[i2];

        QVector3D n = QVector3D::crossProduct(v1 - v0, v2 - v0);
        if (!n.isNull())
            n.normalize();

        normals[i0] += n;
        normals[i1] += n;
        normals[i2] += n;
    }

    // Normalize vertex normals
    for (int i = 0; i < vertexCount_; ++i) {
        if (!normals[i].isNull())
            normals[i].normalize();
    }

    float* dst = reinterpret_cast<float*>(vertexBuffer_.data());
    for (int i = 0; i < vertexCount_; ++i) {
        const auto& v = vertices[i];
        const auto& n = normals[i];
        *dst++ = v.x();
        *dst++ = v.y();
        *dst++ = v.z();

        *dst++ = n.x();
        *dst++ = n.y();
        *dst++ = n.z();
    }

    setVertexData(vertexBuffer_);
    setPrimitiveType(QQuick3DGeometry::PrimitiveType::Triangles);
    setBounds(QVector3D(-2, -2, -2), QVector3D(2, 2, 2)); // loose bounds OK

    update();
}

void SkeletonMeshGeometry::initStaticIndexBuffer()
{
    std::vector<uint32_t> g_smplFaces = loadSMPLFaces(":/qt/qml/HMR_Trial_2/tmp/smpl_faces.txt");

    indexBuffer_.resize(g_smplFaces.size() * sizeof(uint32_t));
    memcpy(indexBuffer_.data(),
           reinterpret_cast<const char*>(g_smplFaces.data()),
           g_smplFaces.size() * sizeof(uint32_t));

    setIndexData(indexBuffer_);
}


std::vector<uint32_t> loadSMPLFaces(const QString& filename)
{
    std::vector<uint32_t> faces;

    QFile file(filename);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qFatal("Cannot open resource file: %s", qPrintable(filename));
    }

    QTextStream in(&file);
    while (!in.atEnd()) {
        QString line = in.readLine().trimmed();
        if (line.isEmpty()) continue;

        QTextStream ls(&line);
        uint32_t a, b, c;

        ls >> a >> b >> c;

        if (ls.status() != QTextStream::Ok) {
            qFatal("Malformed line: %s", qPrintable(line));
        }

        faces.push_back(a);
        faces.push_back(b);
        faces.push_back(c);
    }

    return faces;
}
