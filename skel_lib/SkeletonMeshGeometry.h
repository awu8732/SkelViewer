#pragma once

#include <QtQuick3D/QQuick3DGeometry>
#include <QVector3D>
#include <QVector>

class SkeletonMeshGeometry : public QQuick3DGeometry {
    Q_OBJECT

public:
    explicit SkeletonMeshGeometry(QQuick3DObject* parent = nullptr);

    Q_INVOKABLE void updateVertices(const QVector<QVector3D>& vertices);

private:
    void initStaticIndexBuffer();
    void computeVertexNormals(const QVector<QVector3D> &vertices,
                              QVector<QVector3D> &normals) const;

    void computeBounds(const QVector<QVector3D> &vertices,
                       QVector3D &minB,
                       QVector3D &maxB) const;

    QByteArray vertexBuffer_;
    QByteArray indexBuffer_;
    QByteArray normalBuffer_;

    int vertexCount_ = 0;
};
