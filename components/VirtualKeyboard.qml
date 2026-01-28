import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Item {
    id: root
    property string query: ""
    signal requestClose()
    signal requestClear()
    onVisibleChanged: {
        if (visible) {
            keyboardFocus.forceActiveFocus()
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#000000aa"
    }

    Rectangle {
        id: keyboardPanel
        width: parent.width * 0.7
        height: parent.height * 0.6
        anchors.centerIn: parent
        radius: 16
        color: "#111827"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 16

            Text {
                text: "Buscar: " + root.query
                color: "white"
                font.pixelSize: 20
                elide: Text.ElideRight
            }

            GridLayout {
                id: keyboardGrid
                columns: 10
                columnSpacing: 8
                rowSpacing: 8
                Layout.fillWidth: true

                Repeater {
                    model: [
                        "A","B","C","D","E","F","G","H","I","J",
                        "K","L","M","N","O","P","Q","R","S","T",
                        "U","V","W","X","Y","Z","0","1","2","3",
                        "4","5","6","7","8","9","-","_","."," "
                    ]
                    delegate: KeyButton {
                        label: modelData === " " ? "␣" : modelData
                        onClicked: {
                            root.query += modelData
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                KeyButton {
                    label: "← Borrar"
                    Layout.fillWidth: true
                    onClicked: {
                        if (root.query.length > 0) {
                            root.query = root.query.slice(0, -1)
                        }
                    }
                }
                KeyButton {
                    label: "Limpiar"
                    Layout.fillWidth: true
                    onClicked: root.requestClear()
                }
                KeyButton {
                    label: "Cerrar"
                    Layout.fillWidth: true
                    onClicked: root.requestClose()
                }
            }
        }
    }

    FocusScope {
        id: keyboardFocus
        anchors.fill: parent
        focus: true

        Keys.onPressed: {
            if (event.key === Qt.Key_Escape) {
                root.requestClose()
                event.accepted = true
            }
        }
    }
}
