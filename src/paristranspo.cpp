/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#include <sailfishapp.h>
#include <QtCore/QObject>
#include <QtCore/QDateTime>
#include <QtCore/QTranslator>
#include <QtGui/QGuiApplication>
#include <QtQml/qqml.h>
#include <QtQuick/QQuickView>
#include "manager.h"
#include "place.h"
#include "route.h"
#include "placesearchmodel.h"
#include "routesearchmodel.h"

static const char *TRANSLATION_PATH = "/usr/share/harbour-paristranspo/translations";

static const char *URI = "harbour.paristranspo";
static const char *COLORED_TEXT = "<span style=\"text-decoration:none; color:%1\">%2</span>: %3";
static const char *BUS_PATH = "/usr/share/harbour-paristranspo/data/icons/bus.png";
static const char *METRO_PATH = "/usr/share/harbour-paristranspo/data/icons/metro.png";
static const char *RER_PATH = "/usr/share/harbour-paristranspo/data/icons/rer.png";
static const char *TRAIN_PATH = "/usr/share/harbour-paristranspo/data/icons/train.png";
static const char *TRAM_PATH = "/usr/share/harbour-paristranspo/data/icons/tram.png";
// static const char *WALKING_PATH = "/usr/share/harbour-paristranspo/data/icons/walking.png";
// static const char *WAITING_PATH = "/usr/share/harbour-paristranspo/data/icons/waiting.png";

static const char *ICON = "http://www.vianavigo.com/fileadmin/templates/STIF/picto_ligne_48/%1.png";

class ParisTranspo: public QObject
{
    Q_OBJECT
    Q_ENUMS(Position)
public:
    enum Position {
        UnknownPosition,
        Departure,
        Arrival
    };
    explicit ParisTranspo(QObject *parent = 0);
public slots:
    static void setPlace(RouteSearchModel *model, Position position, Place *place);
    static void initDate(RouteSearchModel *model);
    static void setDate(RouteSearchModel *model, const QDateTime &date);
    static void setTime(RouteSearchModel *model, const QDateTime &time);
    static QString coloredText(const QString &color, const QString &text1, const QString &text2);
    static QString walkSpeed(int speed);
    static QString routeType(int type);
    static QList<QObject *> processedModes(Route *route);
    static QString modeIcon(Mode *mode);
    static QString modeLineIcon(Mode *mode);
};

ParisTranspo::ParisTranspo(QObject *parent)
    : QObject(parent)
{
}

void ParisTranspo::setPlace(RouteSearchModel *model, Position position, Place *place)
{
    switch (position) {
    case Departure:
        model->setDeparture(Place::copy(place, model));
        break;
    case Arrival:
        model->setArrival(Place::copy(place, model));
        break;
    default:
        break;
    }
}

void ParisTranspo::initDate(RouteSearchModel *model)
{
    model->setDate(QDateTime::currentDateTime());
}

void ParisTranspo::setDate(RouteSearchModel *model, const QDateTime &date)
{
    QTime time = model->date().time();
    model->setDate(QDateTime(date.date(), time));
}

void ParisTranspo::setTime(RouteSearchModel *model, const QDateTime &time)
{
    QDate date = model->date().date();
    model->setDate(QDateTime(date, time.time()));
}

QString ParisTranspo::coloredText(const QString &color, const QString &text1, const QString &text2)
{
    return QString(COLORED_TEXT).arg(color, text1, text2);
}

QString ParisTranspo::walkSpeed(int speed)
{
    switch (speed) {
    case RouteSearchModel::Slow:
        //: A walking speed: slow
        //% "Slow walk speed"
        return qtTrId("paristranspo-walk-slow");
        break;
    case RouteSearchModel::Normal:
        //: A walking speed: normal
        //% "Normal walk speed"
        return qtTrId("paristranspo-walk-normal");
        break;
    case RouteSearchModel::Fast:
        //: A walking speed: fast
        //% "Fast walk speed"
        return qtTrId("paristranspo-walk-fast");
        break;
    default:
        return QString();
        break;
    }
}

QString ParisTranspo::routeType(int type)
{
    switch (type) {
    case Route::Faster:
        //: A route type: the fastest
        //% "Fastest"
        return qtTrId("paristranspo-route-fastest");
        break;
    case Route::LessConnections:
        //: A route type: the one with least connections
        //% "Least connections"
        return qtTrId("paristranspo-route-least-connections");
        break;
    case Route::LessWalking:
        //: A route type: the one with least walking
        //% "Least walking"
        return qtTrId("paristranspo-route-least-walking");
        break;
    case Route::NextSchedule:
        //: A route type: the one on the next schedule
        //% "Next schedule"
        return qtTrId("paristranspo-route-next-schedule");
        break;
    case Route::MoreWalking:
        //: A route type: the one with more walking
        //% "More walking"
        return qtTrId("paristranspo-route-more-walking");
        break;
    case Route::OnlyWalking:
        //: A route type: only walking
        //% "Only walking"
        return qtTrId("paristranspo-route-only-walking");
        break;
    default:
        return QString();
        break;
    }
}

QList<QObject *> ParisTranspo::processedModes(Route *route)
{
    QList<QObject *> modes;
    foreach (Mode *mode, route->modes()) {
        if (mode->type() != Mode::Waiting && mode->type() != Mode::Walking) {
            modes.append(mode);
        }
    }
    return modes;
}

QString ParisTranspo::modeIcon(Mode *mode)
{
    QString icon;
    switch (mode->type()) {
    case Mode::Bus:
        icon = BUS_PATH;
        break;
    case Mode::Metro:
        icon = METRO_PATH;
        break;
    case Mode::Rer:
        icon = RER_PATH;
        break;
    case Mode::Ter:
        icon = TRAIN_PATH;
        break;
    case Mode::Train:
        icon = TRAIN_PATH;
        break;
    case Mode::Tram:
        icon = TRAM_PATH;
        break;
    case Mode::TZen:
        icon = BUS_PATH;
        break;
    case Mode::Val:
        icon = BUS_PATH;
        break;
    default:
        break;
    }

    return icon;
}

QString ParisTranspo::modeLineIcon(Mode *mode)
{
    return QString(ICON).arg(mode->externalCode().replace(":", "_"));
}

static QObject *paristranspo_provider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    ParisTranspo *parisTranspo = new ParisTranspo();
    return parisTranspo;
}

void defineImports()
{
    // @uri harbour.paristranspo
    qmlRegisterSingletonType<ParisTranspo>(URI, 1, 0, "ParisTranspo", paristranspo_provider);
    qmlRegisterType<Manager>(URI, 1, 0, "Manager");
    qmlRegisterType<Place>(URI, 1, 0, "Place");
    qmlRegisterType<Route>(URI, 1, 0, "Route");
    qmlRegisterType<Mode>(URI, 1, 0, "Mode");
    qmlRegisterType<PlaceSearchModel>(URI, 1, 0, "PlaceSearchModel");
    qmlRegisterType<RouteSearchModel>(URI, 1, 0, "RouteSearchModel");
}

int main(int argc, char *argv[])
{
    defineImports();

    QScopedPointer<QTranslator> engineeringEnglish(new QTranslator);
    QScopedPointer<QTranslator> translator(new QTranslator);
    engineeringEnglish->load("paristranspo-engineering-english", TRANSLATION_PATH);
    translator->load(QLocale(), "friends", "_", TRANSLATION_PATH);
    QGuiApplication *app = SailfishApp::application(argc, argv);

    app->installTranslator(engineeringEnglish.data());
    app->installTranslator(translator.data());

    QQuickView *view = SailfishApp::createView();
    view->setSource(SailfishApp::pathTo("qml/harbour-paristranspo.qml"));
    view->showFullScreen();

    int result = app->exec();
    app->removeTranslator(translator.data());
    app->removeTranslator(engineeringEnglish.data());
    return result;
}

#include "paristranspo.moc"
