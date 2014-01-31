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
#include <QtQml/qqml.h>
#include "manager.h"
#include "place.h"
#include "placesearchmodel.h"

static const char *URI = "harbour.paristranspo";

class ParisTranspo: public QObject
{
    Q_OBJECT
    Q_ENUMS(Position)
    Q_PROPERTY(Place * departure READ departure NOTIFY departureChanged)
    Q_PROPERTY(Place * arrival READ arrival NOTIFY arrivalChanged)
public:
    enum Position {
        UnknownPosition,
        Departure,
        Arrival
    };
    explicit ParisTranspo(QObject *parent = 0);
    Place * departure() const;
    Place * arrival() const;
signals:
    void departureChanged();
    void arrivalChanged();
public slots:
    void setPlace(Position position, Place *place);
private:
    Place *m_departure;
    Place *m_arrival;
};

ParisTranspo::ParisTranspo(QObject *parent)
    : QObject(parent), m_departure(0), m_arrival(0)
{
}

Place * ParisTranspo::departure() const
{
    return m_departure;
}

Place * ParisTranspo::arrival() const
{
    return m_arrival;
}

void ParisTranspo::setPlace(Position position, Place *place)
{
    switch (position) {
    case Departure:
        m_departure = Place::copy(place, this);
        emit departureChanged();
        break;
    case Arrival:
        m_arrival = Place::copy(place, this);
        emit arrivalChanged();
        break;
    default:
        break;
    }
}

void defineImports()
{
    // @uri harbour.paristranspo
    qmlRegisterType<ParisTranspo>(URI, 1, 0, "ParisTranspo");
    qmlRegisterType<Manager>(URI, 1, 0, "Manager");
    qmlRegisterType<Place>(URI, 1, 0, "Place");
    qmlRegisterType<PlaceSearchModel>(URI, 1, 0, "PlaceSearchModel");
}

int main(int argc, char *argv[])
{
    defineImports();
    return SailfishApp::main(argc, argv);
}

#include "paristranspo.moc"
