import QtQuick 2.12
import QtQuick.Controls 2.12

Item {
    id: root
    property var model
    property string imageSource: ""
    signal currentGameChanged(var currentGame)
    signal requestToggleFavorite()
    signal requestCycleImage()
    signal requestOpenSearch()

    ListView {
        id: listView
        anchors.fill: parent
        model: root.model
        spacing: 12
        focus: true
        clip: true
        delegate: Rectangle {
            width: listView.width
            height: 72
            color: ListView.isCurrentItem ? "#4c51bf" : "#1f2937"
            radius: 8

            Row {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 16

                Image {
                    width: 90
                    height: 52
                    fillMode: Image.PreserveAspectFit
                    source: root.imageSource
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 4

                    Text {
                        text: model.title || model.name || ""
                        color: "white"
                        font.pixelSize: 18
                        elide: Text.ElideRight
                        width: listView.width - 140
                    }
                    Text {
                        text: model.favorite ? "★ Favorito" : ""
                        color: "#fbbf24"
                        font.pixelSize: 14
                    }
                }
            }
        }
        onCurrentIndexChanged: {
            var game = root.model && root.model.count > 0 ? root.model.get(currentIndex) : null
            root.currentGameChanged(game)
        }
    }

    Keys.onPressed: {
        if (event.key === Qt.Key_X) {
            root.requestCycleImage()
            event.accepted = true
        } else if (event.key === Qt.Key_Y) {
            root.requestToggleFavorite()
            event.accepted = true
        } else if (event.key === Qt.Key_S) {
            root.requestOpenSearch()
            event.accepted = true
        }
    }
}
