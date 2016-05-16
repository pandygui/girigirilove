import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Window 2.2
import QtMultimedia 5.5

import "./Component"

Window {
    id: appWindow
    visible: true
    visibility: Window.Maximized
    title: qsTr("ギリギリ")

    Timer {
        interval: 5 * 1000
        repeat: true
        running: player.playbackState === MediaPlayer.PlayingState
        onTriggered: 更换背景()
    }

    Item {
        anchors.fill: parent
        AnimatedImage {
            id: a
            opacity: 1
            anchors.fill: parent
            source: "./girigirilove/01.gif"
            playing: player.playbackState === MediaPlayer.PlayingState
            fillMode: Image.Tile
            Behavior on opacity {
                NumberAnimation { duration: 1000 }
            }
        }
        AnimatedImage {
            id: b
            opacity: 0
            anchors.fill: parent
            source: "./girigirilove/05.gif"
            playing: player.playbackState === MediaPlayer.PlayingState
            fillMode: Image.Tile
            Behavior on opacity {
                NumberAnimation { duration: 1000 }
            }
        }
    }

    readonly property var 图片们: [
        "./girigirilove/01.gif",
        "./girigirilove/02.gif",
        "./girigirilove/03.gif",
        "./girigirilove/04.gif",
        "./girigirilove/05.gif",
        "./girigirilove/06.gif",
        "./girigirilove/07.gif",
        "./girigirilove/08.gif",
        "./girigirilove/09.gif",
        "./girigirilove/10.gif",
        "./girigirilove/11.gif",
        // "./girigirilove/00.gif",
    ]

    function 更换背景(){
        if(a.opacity === 0) {
            a.source = 图片们[Math.floor(图片们.length*Math.random())];
        } else if(b.opacity === 0) {
            b.source = 图片们[Math.floor(图片们.length*Math.random())];
        }
        a.opacity = 1 - a.opacity;
        b.opacity = 1- b.opacity;
    }

    VideoOutput {
        id: videoOutput
        source: player
        anchors.fill: parent
        property alias totalTime: player.totalTime

        ErrorDialog{
            player:player
        }

        MediaPlayer {
            id: player
            loops:MediaPlayer.Infinite
            source: "./girigirilove/いけないボーダーライン.m4a"
            readonly property int minutes: Math.floor(player.duration / 60000)
            readonly property int seconds: Math.round((player.duration % 60000) / 1000)
            readonly property int hours : (player.duration / 3600000 > 1) ?Math.floor(player.duration / 3600000):0
            readonly property string totalTime:Qt.formatTime(new Date(0, 0, 0, hours, minutes, seconds), qsTr("hh:mm:ss"))

        }

        readonly property int minutes: Math.floor(player.position / 60000)
        readonly property int seconds: Math.round((player.position % 60000) / 1000)
        readonly property int hours : (player.position / 3600000 > 1) ?Math.floor(player.position / 3600000):0
        readonly property string positionTime:Qt.formatTime(new Date(0, 0, 0, hours, minutes, seconds), qsTr("hh:mm:ss"))


        MouseArea{
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
            onClicked: {
                if(mouse.button == Qt.LeftButton){
                    player.playbackState == MediaPlayer.PlayingState ? player.pause() : player.play();
                }
                if(mouse.button == Qt.RightButton){
                    menu.open(mouse.x,mouse.y);
                } else {
                    menu.close();
                }

            }
            onWheel:{
                // down
                if(wheel.angleDelta.y < 0) {
                    if(player.volume != 0) player.volume -=0.1;
                } else if(wheel.angleDelta.y > 0){
                    if(player.volume != 1)  player.volume +=0.1;
                }
            }

            // 以下是键盘控制
            //=============================================================================================
            focus: true;
            Keys.onSpacePressed: player.playbackState == MediaPlayer.PlayingState ? player.pause() : player.play();
            Keys.onLeftPressed: player.seek(player.position - 5000);
            Keys.onRightPressed: player.seek(player.position + 5000);
            Keys.onEscapePressed: appWindow.visibility = Window.Maximized;
            Keys.onReturnPressed: appWindow.visibility =
                                  (appWindow.visibility == Window.FullScreen)?
                                      Window.Windowed:Window.FullScreen;
            Keys.onUpPressed: {
                if(player.volume != 1){
                    player.volume +=0.1;
                }
            }
            Keys.onDownPressed: {
                if(player.volume != 0){
                    player.volume -=0.1;
                }
            }
            Keys.onPressed: {
                // hide bar
                if ((event.key == Qt.Key_H) && (event.modifiers & Qt.ControlModifier)){
                    bar.visible = !bar.visible;
                }

                if (event.key == Qt.Key_H){
                    bar.visible = !bar.visible;
                }
            }
        }
        //=============================================================================================

        MouseClickedMenu{
            id:menu;
            Column{
                spacing: 10;
                Rectangle{
                    width: menu.width;
                    height: 20;
                    color:"#fbed90";
                    Text{
                        anchors.centerIn: parent;
                        text:qsTr("隐藏菜单");
                    }
                }
                Text{
                    text:(player.loops < 0)?"在洗脑循环中":"就一次！";
                    MouseArea{
                        anchors.fill: parent;
                        onClicked: (player.loops != -1)?(player.loops = MediaPlayer.Infinite ):(player.loops = 1);
                    }
                }

                Text{
                    text:bar.visible?"隐藏播放栏":"显示播放栏";
                    MouseArea{
                        anchors.fill: parent;
                        onClicked: bar.visible?(bar.visible = false):(bar.visible = true);
                    }
                }
            }
        }
    }

    PlayerBar{
        id:bar;
        player:player;
        anchors.bottom: parent.bottom
    }
}
