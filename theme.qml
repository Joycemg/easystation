import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "components"

FocusScope {
    id: root
    width: 1280
    height: 720
    focus: true

    property var imageModes: ["boxFront", "screenshot", "titleScreen"]
    property int imageModeIndex: 0
    property string searchQuery: ""
    property bool keyboardVisible: false

    property var collectionsModel: ListModel {}
    property var favoritesModel: ListModel {}
    property var filteredGamesModel: ListModel {}

    property int currentCollectionIndex: 0
    property var currentCollection: null
    property var currentGame: null

    function buildCollections() {
        collectionsModel.clear()
        collectionsModel.append({ name: "★ Favoritos", games: favoritesModel, isFavorites: true })
        for (var i = 0; i < api.collections.count; ++i) {
            var collection = api.collections.get(i)
            collectionsModel.append({ name: collection.name, games: collection.games, isFavorites: false })
        }
        currentCollectionIndex = 0
        currentCollection = collectionsModel.get(currentCollectionIndex)
        updateFilteredGames()
    }

    function updateFavoritesModel() {
        favoritesModel.clear()
        if (!api.allGames) {
            return
        }
        for (var i = 0; i < api.allGames.count; ++i) {
            var game = api.allGames.get(i)
            if (game.favorite) {
                favoritesModel.append(game)
            }
        }
        if (currentCollection && currentCollection.isFavorites) {
            updateFilteredGames()
        }
    }

    function updateFilteredGames() {
        filteredGamesModel.clear()
        if (!currentCollection) {
            return
        }
        var gamesModel = currentCollection.games
        if (!gamesModel) {
            return
        }
        var normalized = searchQuery.toLowerCase()
        for (var i = 0; i < gamesModel.count; ++i) {
            var game = gamesModel.get(i)
            var name = game.title || game.name || ""
            if (normalized.length === 0 || name.toLowerCase().indexOf(normalized) !== -1) {
                filteredGamesModel.append(game)
            }
        }
        currentGame = filteredGamesModel.count > 0 ? filteredGamesModel.get(0) : null
    }

    function gameImage(game) {
        if (!game) {
            return ""
        }
        var mode = imageModes[imageModeIndex]
        if (mode === "boxFront") {
            return game.assets.boxFront
        }
        if (mode === "screenshot") {
            return game.assets.screenshot
        }
        return game.assets.titleScreen
    }

    function toggleFavorite() {
        if (!currentGame) {
            return
        }
        currentGame.favorite = !currentGame.favorite
        updateFavoritesModel()
    }

    function cycleImageMode() {
        imageModeIndex = (imageModeIndex + 1) % imageModes.length
    }

    function openSearch() {
        keyboardVisible = true
    }

    function closeSearch() {
        keyboardVisible = false
    }

    Keys.onPressed: {
        if (event.key === Qt.Key_X) {
            cycleImageMode()
            event.accepted = true
        } else if (event.key === Qt.Key_Y) {
            toggleFavorite()
            event.accepted = true
        } else if (event.key === Qt.Key_S) {
            openSearch()
            event.accepted = true
        } else if (event.key === Qt.Key_Escape && keyboardVisible) {
            closeSearch()
            event.accepted = true
        }
    }

    Component.onCompleted: {
        buildCollections()
        updateFavoritesModel()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 32
        spacing: 24

        RowLayout {
            Layout.fillWidth: true
            spacing: 24

            ListView {
                id: collectionList
                Layout.preferredWidth: 260
                Layout.fillHeight: true
                model: collectionsModel
                currentIndex: currentCollectionIndex
                delegate: Rectangle {
                    width: collectionList.width
                    height: 40
                    color: ListView.isCurrentItem ? "#2b6cb0" : "#1a202c"
                    radius: 6

                    Text {
                        anchors.centerIn: parent
                        text: model.name
                        color: "white"
                        font.pixelSize: 18
                    }
                }
                onCurrentIndexChanged: {
                    currentCollectionIndex = currentIndex
                    currentCollection = collectionsModel.get(currentIndex)
                    updateFilteredGames()
                }
            }

            GameList {
                id: gameList
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: filteredGamesModel
                imageSource: gameImage(model.get(index))
                onCurrentGameChanged: {
                    root.currentGame = currentGame
                }
                onRequestToggleFavorite: {
                    root.toggleFavorite()
                }
                onRequestCycleImage: {
                    root.cycleImageMode()
                }
                onRequestOpenSearch: {
                    root.openSearch()
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 140
            radius: 12
            color: "#111827"
            RowLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 16

                Image {
                    id: previewImage
                    Layout.preferredWidth: 220
                    Layout.preferredHeight: 120
                    fillMode: Image.PreserveAspectFit
                    source: gameImage(currentGame)
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Text {
                        text: currentGame ? (currentGame.title || currentGame.name) : "Sin juegos"
                        color: "white"
                        font.pixelSize: 22
                        elide: Text.ElideRight
                    }
                    Text {
                        text: "Imagen: " + imageModes[imageModeIndex]
                        color: "#9ca3af"
                        font.pixelSize: 16
                    }
                    Text {
                        text: "Y: Favorito | X: Cambiar imagen | Start/S: Buscar"
                        color: "#6b7280"
                        font.pixelSize: 14
                    }
                }
            }
        }
    }

    VirtualKeyboard {
        id: keyboard
        anchors.fill: parent
        visible: keyboardVisible
        query: searchQuery
        onQueryChanged: {
            searchQuery = query
            updateFilteredGames()
        }
        onRequestClose: {
            closeSearch()
        }
        onRequestClear: {
            searchQuery = ""
            updateFilteredGames()
        }
    }
}
