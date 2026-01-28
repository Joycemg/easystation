import QtQuick 2.12
import QtQuick.Controls 2.12

Button {
    id: root
    property string label: ""
    text: label
    font.pixelSize: 16
    background: Rectangle {
        radius: 8
        color: root.down ? "#4c51bf" : "#1f2937"
        border.color: "#4b5563"
    }
    contentItem: Text {
        text: root.text
        color: "white"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
