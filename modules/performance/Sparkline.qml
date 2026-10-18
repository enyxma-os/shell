import QtQuick
import "../../services"

Canvas {
    id: spark

    property real value: 0
    property real max: 100
    property int samples: 30
    property int intervalMs: 1000
    property bool active: false
    property color lineColor: Theme.accent
    property real fillOpacity: 0.15

    property var _buf: []

    implicitHeight: 36
    onActiveChanged: {
        if (!active) {
            _buf = []
            requestPaint()
        }
    }

    onPaint: {
        var ctx = getContext("2d")
        ctx.clearRect(0, 0, width, height)
        var n = _buf.length
        if (n < 2) return

        var dx = width / Math.max(1, samples - 1)
        var x0 = width - (n - 1) * dx

        // Çizgi grafiğini çiz
        ctx.beginPath()
        for (var i = 0; i < n; i++) {
            var frac = Math.max(0, Math.min(1, _buf[i] / spark.max))
            var x = x0 + i * dx
            var y = height - 1 - frac * (height - 2)
            if (i === 0)
                ctx.moveTo(x, y)
            else
                ctx.lineTo(x, y)
        }
        ctx.strokeStyle = spark.lineColor
        ctx.lineWidth = 1.5
        ctx.stroke()

        // Alt dolgu alanını çiz
        ctx.lineTo(x0 + (n - 1) * dx, height)
        ctx.lineTo(x0, height)
        ctx.closePath()
        ctx.fillStyle = Qt.rgba(spark.lineColor.r, spark.lineColor.g, spark.lineColor.b, spark.fillOpacity)
        ctx.fill()
    }

    Timer {
        interval: spark.intervalMs
        running: spark.active
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            spark._buf.push(spark.value)
            if (spark._buf.length > spark.samples)
                spark._buf.shift()
            spark.requestPaint()
        }
    }
}
