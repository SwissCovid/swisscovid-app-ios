/*
 * Copyright (c) 2020 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import Foundation

class NSMoreTestInformationPopupViewController: NSPopupViewController {
    init() {
        super.init(showCloseButton: true,
                   dismissable: true,
                   stackViewInset: .init(top: NSPadding.large, left: NSPadding.large, bottom: NSPadding.large, right: NSPadding.large))
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tintColor = .ns_purple

        let subtitleText = "symptom_detail_box_subtitle".ub_localized
        let subtitleLabel = NSLabel(.textBold, textColor: .ns_purple)
        subtitleLabel.text = subtitleText
        subtitleLabel.accessibilityLabel = subtitleText.deleteSuffix("...")

        stackView.addArrangedSubview(subtitleLabel)
        stackView.addSpacerView(NSPadding.small)

        let titleText = "test_location_popup_title".ub_localized
        let titleLabel = NSLabel(.title)
        titleLabel.text = titleText
        stackView.addArrangedSubview(titleLabel)
        stackView.addSpacerView(NSPadding.large)

        let textLabel = NSLabel(.textLight)
        textLabel.text = "test_location_popup_text".ub_localized
        stackView.addArrangedSubview(textLabel)
        stackView.addSpacerView(NSPadding.large)

        let testLocations = ConfigManager.currentConfig?.testLocations ?? DefaultFactory.defaultLocations
        if let locations = testLocations.value {
            for (index, location) in locations.enumerated() {
                let externalLinkButton = NSExternalLinkButton(style: .normal(color: .ns_purple), size: .normal, linkType: .url)
                externalLinkButton.title = location.region.ub_localized
                externalLinkButton.touchUpCallback = { [weak self] in
                    self?.openUrl(location.url)
                }
                stackView.addArrangedSubview(externalLinkButton)
                if index != (locations.count - 1) {
                    stackView.addSpacerView(NSPadding.medium)
                }
            }
        }
    }

    private func openUrl(_ url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

enum DefaultFactory {
    static var defaultLocations: LocalizedValue<[ConfigResponseBody.TestLocation]> {
        let json = """
        {
            "de": [
              {
                "region": "canton_aargau",
                "url": "https://www.ag.ch/de/themen_1/coronavirus_2/coronavirus.jsp"
              },
              {
                "region": "canton_appenzell_ausserrhoden",
                "url": "https://www.ar.ch/verwaltung/departement-gesundheit-und-soziales/amt-fuer-gesundheit/informationsseite-coronavirus/"
              },
              {
                "region": "canton_appenzell_innerrhoden",
                "url": "https://www.ai.ch/themen/gesundheit-alter-und-soziales/gesundheitsfoerderung-und-praevention/uebertragbare-krankheiten/coronavirus"
              },
              {
                "region": "canton_basel_country",
                "url": "https://www.baselland.ch/politik-und-behorden/direktionen/volkswirtschafts-und-gesundheitsdirektion/amt-fur-gesundheit/medizinische-dienste/kantonsarztlicher-dienst/aktuelles"
              },
              {
                "region": "canton_basel_city",
                "url": "https://www.coronavirus.bs.ch/"
              },
              {
                "region": "canton_berne",
                "url": "http://www.be.ch/corona"
              },
              {
                "region": "canton_fribourg",
                "url": "https://www.fr.ch/de/gesundheit/covid-19/coronavirus-aktuelle-informationen-alle-news-in-zusammenhang-mit-covid-19-getroffene-massnahmen-faq"
              },
              {
                "region": "canton_geneva",
                "url": "https://www.ge.ch/covid-19-se-proteger-proteger-autres"
              },
              {
                "region": "canton_glarus",
                "url": "https://www.gl.ch/verwaltung/finanzen-und-gesundheit/gesundheit/coronavirus.html/4817"
              },
              {
                "region": "canton_graubuenden",
                "url": "https://www.gr.ch/DE/institutionen/verwaltung/djsg/ga/coronavirus/info/Seiten/Start.aspx"
              },
              {
                "region": "canton_jura",
                "url": "https://www.jura.ch/fr/Autorites/Coronavirus/Accueil/Coronavirus-Informations-officielles-a-la-population-jurassienne.html"
              },
              {
                "region": "canton_lucerne",
                "url": "https://gesundheit.lu.ch/themen/Humanmedizin/Infektionskrankheiten/Informationen_Coronavirus"
              },
              {
                "region": "canton_neuchatel",
                "url": "https://www.ne.ch/autorites/DFS/SCSP/medecin-cantonal/maladies-vaccinations/Pages/Coronavirus.aspx"
              },
              {
                "region": "canton_nidwalden",
                "url": "https://www.nw.ch/gesundheitsamtdienste/6044"
              },
              {
                "region": "canton_obwalden",
                "url": "https://www.ow.ch/de/verwaltung/dienstleistungen/?dienst_id=5962"
              },
              {
                "region": "canton_st_gallen",
                "url": "https://www.sg.ch/tools/informationen-coronavirus.html"
              },
              {
                "region": "canton_schaffhausen",
                "url": "https://sh.ch/CMS/Webseite/Kanton-Schaffhausen/Beh-rde/Verwaltung/Departement-des-Innern/Gesundheitsamt-2954701-DE.html"
              },
              {
                "region": "canton_schwyz",
                "url": "https://www.sz.ch/behoerden/information-medien/medienmitteilungen/coronavirus.html/72-416-412-1379-6948"
              },
              {
                "region": "canton_solothurn",
                "url": "https://corona.so.ch/"
              },
              {
                "region": "canton_thurgovia",
                "url": "https://www.tg.ch/news/fachdossier-coronavirus.html/10552"
              },
              {
                "region": "canton_ticino",
                "url": "https://www4.ti.ch/dss/dsp/covid19/home/"
              },
              {
                "region": "canton_uri",
                "url": "https://www.ur.ch/themen/2962"
              },
              {
                "region": "canton_valais",
                "url": "https://www.vs.ch/de/web/coronavirus/home"
              },
              {
                "region": "canton_vaud",
                "url": "https://www.vd.ch/toutes-les-actualites/hotline-et-informations-sur-le-coronavirus/"
              },
              {
                "region": "canton_zug",
                "url": "https://www.zg.ch/behoerden/gesundheitsdirektion/amt-fuer-gesundheit/corona"
              },
              {
                "region": "canton_zurich",
                "url": "https://www.zh.ch/de/gesundheit/coronavirus.html"
              },
              {
                "region": "country_liechtenstein",
                "url": "https://www.llv.li/inhalt/118724/amtsstellen/coronavirus"
              }
            ],
            "fr": [
              {
                "region": "canton_aargau",
                "url": "https://www.ag.ch/de/themen_1/coronavirus_2/coronavirus.jsp"
              },
              {
                "region": "canton_appenzell_ausserrhoden",
                "url": "https://www.ar.ch/verwaltung/departement-gesundheit-und-soziales/amt-fuer-gesundheit/informationsseite-coronavirus/"
              },
              {
                "region": "canton_appenzell_innerrhoden",
                "url": "https://www.ai.ch/themen/gesundheit-alter-und-soziales/gesundheitsfoerderung-und-praevention/uebertragbare-krankheiten/coronavirus"
              },
              {
                "region": "canton_basel_country",
                "url": "https://www.baselland.ch/politik-und-behorden/direktionen/volkswirtschafts-und-gesundheitsdirektion/amt-fur-gesundheit/medizinische-dienste/kantonsarztlicher-dienst/aktuelles"
              },
              {
                "region": "canton_basel_city",
                "url": "https://www.coronavirus.bs.ch/"
              },
              {
                "region": "canton_berne",
                "url": "http://www.be.ch/corona"
              },
              {
                "region": "canton_fribourg",
                "url": "https://www.fr.ch/sante/covid-19/coronavirus-informations-actuelles-toutes-les-actualites-liees-au-covid-19-mesures-prises-faq-statistiques"
              },
              {
                "region": "canton_geneva",
                "url": "https://www.ge.ch/covid-19-se-proteger-proteger-autres"
              },
              {
                "region": "canton_glarus",
                "url": "https://www.gl.ch/verwaltung/finanzen-und-gesundheit/gesundheit/coronavirus.html/4817"
              },
              {
                "region": "canton_graubuenden",
                "url": "https://www.gr.ch/DE/institutionen/verwaltung/djsg/ga/coronavirus/info/Seiten/Start.aspx"
              },
              {
                "region": "canton_jura",
                "url": "https://www.jura.ch/fr/Autorites/Coronavirus/Accueil/Coronavirus-Informations-officielles-a-la-population-jurassienne.html"
              },
              {
                "region": "canton_lucerne",
                "url": "https://gesundheit.lu.ch/themen/Humanmedizin/Infektionskrankheiten/Informationen_Coronavirus"
              },
              {
                "region": "canton_neuchatel",
                "url": "https://www.ne.ch/autorites/DFS/SCSP/medecin-cantonal/maladies-vaccinations/Pages/Coronavirus.aspx"
              },
              {
                "region": "canton_nidwalden",
                "url": "https://www.nw.ch/gesundheitsamtdienste/6044"
              },
              {
                "region": "canton_obwalden",
                "url": "https://www.ow.ch/de/verwaltung/dienstleistungen/?dienst_id=5962"
              },
              {
                "region": "canton_st_gallen",
                "url": "https://www.sg.ch/tools/informationen-coronavirus.html"
              },
              {
                "region": "canton_schaffhausen",
                "url": "https://sh.ch/CMS/Webseite/Kanton-Schaffhausen/Beh-rde/Verwaltung/Departement-des-Innern/Gesundheitsamt-2954701-DE.html"
              },
              {
                "region": "canton_schwyz",
                "url": "https://www.sz.ch/behoerden/information-medien/medienmitteilungen/coronavirus.html/72-416-412-1379-6948"
              },
              {
                "region": "canton_solothurn",
                "url": "https://corona.so.ch/"
              },
              {
                "region": "canton_thurgovia",
                "url": "https://www.tg.ch/news/fachdossier-coronavirus.html/10552"
              },
              {
                "region": "canton_ticino",
                "url": "https://www4.ti.ch/dss/dsp/covid19/home/"
              },
              {
                "region": "canton_uri",
                "url": "https://www.ur.ch/themen/2962"
              },
              {
                "region": "canton_valais",
                "url": "https://www.vs.ch/web/coronavirus/"
              },
              {
                "region": "canton_vaud",
                "url": "https://www.vd.ch/toutes-les-actualites/hotline-et-informations-sur-le-coronavirus/"
              },
              {
                "region": "canton_zug",
                "url": "https://www.zg.ch/behoerden/gesundheitsdirektion/amt-fuer-gesundheit/corona"
              },
              {
                "region": "canton_zurich",
                "url": "https://www.zh.ch/de/gesundheit/coronavirus.html"
              },
              {
                "region": "country_liechtenstein",
                "url": "https://www.llv.li/inhalt/118724/amtsstellen/coronavirus"
              }
            ],
            "it": [
              {
                "region": "canton_aargau",
                "url": "https://www.ag.ch/de/themen_1/coronavirus_2/coronavirus.jsp"
              },
              {
                "region": "canton_appenzell_ausserrhoden",
                "url": "https://www.ar.ch/verwaltung/departement-gesundheit-und-soziales/amt-fuer-gesundheit/informationsseite-coronavirus/"
              },
              {
                "region": "canton_appenzell_innerrhoden",
                "url": "https://www.ai.ch/themen/gesundheit-alter-und-soziales/gesundheitsfoerderung-und-praevention/uebertragbare-krankheiten/coronavirus"
              },
              {
                "region": "canton_basel_country",
                "url": "https://www.baselland.ch/politik-und-behorden/direktionen/volkswirtschafts-und-gesundheitsdirektion/amt-fur-gesundheit/medizinische-dienste/kantonsarztlicher-dienst/aktuelles"
              },
              {
                "region": "canton_basel_city",
                "url": "https://www.coronavirus.bs.ch/"
              },
              {
                "region": "canton_berne",
                "url": "http://www.be.ch/corona"
              },
              {
                "region": "canton_fribourg",
                "url": "https://www.fr.ch/sante/covid-19/coronavirus-informations-actuelles-toutes-les-actualites-liees-au-covid-19-mesures-prises-faq-statistiques"
              },
              {
                "region": "canton_geneva",
                "url": "https://www.ge.ch/covid-19-se-proteger-proteger-autres"
              },
              {
                "region": "canton_glarus",
                "url": "https://www.gl.ch/verwaltung/finanzen-und-gesundheit/gesundheit/coronavirus.html/4817"
              },
              {
                "region": "canton_graubuenden",
                "url": "https://www.gr.ch/IT/istituzioni/amministrazione/djsg/ga/coronavirus/info/Seiten/Start.aspx"
              },
              {
                "region": "canton_jura",
                "url": "https://www.jura.ch/fr/Autorites/Coronavirus/Accueil/Coronavirus-Informations-officielles-a-la-population-jurassienne.html"
              },
              {
                "region": "canton_lucerne",
                "url": "https://gesundheit.lu.ch/themen/Humanmedizin/Infektionskrankheiten/Informationen_Coronavirus"
              },
              {
                "region": "canton_neuchatel",
                "url": "https://www.ne.ch/autorites/DFS/SCSP/medecin-cantonal/maladies-vaccinations/Pages/Coronavirus.aspx"
              },
              {
                "region": "canton_nidwalden",
                "url": "https://www.nw.ch/gesundheitsamtdienste/6044"
              },
              {
                "region": "canton_obwalden",
                "url": "https://www.ow.ch/de/verwaltung/dienstleistungen/?dienst_id=5962"
              },
              {
                "region": "canton_st_gallen",
                "url": "https://www.sg.ch/tools/informationen-coronavirus.html"
              },
              {
                "region": "canton_schaffhausen",
                "url": "https://sh.ch/CMS/Webseite/Kanton-Schaffhausen/Beh-rde/Verwaltung/Departement-des-Innern/Gesundheitsamt-2954701-DE.html"
              },
              {
                "region": "canton_schwyz",
                "url": "https://www.sz.ch/behoerden/information-medien/medienmitteilungen/coronavirus.html/72-416-412-1379-6948"
              },
              {
                "region": "canton_solothurn",
                "url": "https://corona.so.ch/"
              },
              {
                "region": "canton_thurgovia",
                "url": "https://www.tg.ch/news/fachdossier-coronavirus.html/10552"
              },
              {
                "region": "canton_ticino",
                "url": "https://www4.ti.ch/dss/dsp/covid19/home/"
              },
              {
                "region": "canton_uri",
                "url": "https://www.ur.ch/themen/2962"
              },
              {
                "region": "canton_valais",
                "url": "https://www.vs.ch/web/coronavirus/"
              },
              {
                "region": "canton_vaud",
                "url": "https://www.vd.ch/toutes-les-actualites/hotline-et-informations-sur-le-coronavirus/"
              },
              {
                "region": "canton_zug",
                "url": "https://www.zg.ch/behoerden/gesundheitsdirektion/amt-fuer-gesundheit/corona"
              },
              {
                "region": "canton_zurich",
                "url": "https://www.zh.ch/de/gesundheit/coronavirus.html"
              },
              {
                "region": "country_liechtenstein",
                "url": "https://www.llv.li/inhalt/118724/amtsstellen/coronavirus"
              }
            ],
            "en": [
              {
                "region": "canton_aargau",
                "url": "https://www.ag.ch/de/themen_1/coronavirus_2/coronavirus.jsp"
              },
              {
                "region": "canton_appenzell_ausserrhoden",
                "url": "https://www.ar.ch/verwaltung/departement-gesundheit-und-soziales/amt-fuer-gesundheit/informationsseite-coronavirus/"
              },
              {
                "region": "canton_appenzell_innerrhoden",
                "url": "https://www.ai.ch/themen/gesundheit-alter-und-soziales/gesundheitsfoerderung-und-praevention/uebertragbare-krankheiten/coronavirus"
              },
              {
                "region": "canton_basel_country",
                "url": "https://www.baselland.ch/politik-und-behorden/direktionen/volkswirtschafts-und-gesundheitsdirektion/amt-fur-gesundheit/medizinische-dienste/kantonsarztlicher-dienst/aktuelles"
              },
              {
                "region": "canton_basel_city",
                "url": "https://www.coronavirus.bs.ch/en.html"
              },
              {
                "region": "canton_berne",
                "url": "http://www.be.ch/corona"
              },
              {
                "region": "canton_fribourg",
                "url": "https://www.fr.ch/sante/covid-19/coronavirus-informations-actuelles-toutes-les-actualites-liees-au-covid-19-mesures-prises-faq-statistiques"
              },
              {
                "region": "canton_geneva",
                "url": "https://www.ge.ch/en/covid-19-how-protect-yourself-and-others"
              },
              {
                "region": "canton_glarus",
                "url": "https://www.gl.ch/verwaltung/finanzen-und-gesundheit/gesundheit/coronavirus.html/4817"
              },
              {
                "region": "canton_graubuenden",
                "url": "https://www.gr.ch/DE/institutionen/verwaltung/djsg/ga/coronavirus/info/Seiten/Start.aspx"
              },
              {
                "region": "canton_jura",
                "url": "https://www.jura.ch/fr/Autorites/Coronavirus/Accueil/Coronavirus-Informations-officielles-a-la-population-jurassienne.html"
              },
              {
                "region": "canton_lucerne",
                "url": "https://gesundheit.lu.ch/themen/Humanmedizin/Infektionskrankheiten/Informationen_Coronavirus"
              },
              {
                "region": "canton_neuchatel",
                "url": "https://www.ne.ch/autorites/DFS/SCSP/medecin-cantonal/maladies-vaccinations/Pages/Coronavirus.aspx"
              },
              {
                "region": "canton_nidwalden",
                "url": "https://www.nw.ch/gesundheitsamtdienste/6044"
              },
              {
                "region": "canton_obwalden",
                "url": "https://www.ow.ch/de/verwaltung/dienstleistungen/?dienst_id=5962"
              },
              {
                "region": "canton_st_gallen",
                "url": "https://www.sg.ch/tools/informationen-coronavirus.html"
              },
              {
                "region": "canton_schaffhausen",
                "url": "https://sh.ch/CMS/Webseite/Kanton-Schaffhausen/Beh-rde/Verwaltung/Departement-des-Innern/Gesundheitsamt-2954701-DE.html"
              },
              {
                "region": "canton_schwyz",
                "url": "https://www.sz.ch/behoerden/information-medien/medienmitteilungen/coronavirus.html/72-416-412-1379-6948"
              },
              {
                "region": "canton_solothurn",
                "url": "https://corona.so.ch/"
              },
              {
                "region": "canton_thurgovia",
                "url": "https://www.tg.ch/news/fachdossier-coronavirus.html/10552"
              },
              {
                "region": "canton_ticino",
                "url": "https://www4.ti.ch/dss/dsp/covid19/home/"
              },
              {
                "region": "canton_uri",
                "url": "https://www.ur.ch/themen/2962"
              },
              {
                "region": "canton_valais",
                "url": "https://www.vs.ch/web/coronavirus/"
              },
              {
                "region": "canton_vaud",
                "url": "https://www.vd.ch/toutes-les-actualites/hotline-et-informations-sur-le-coronavirus/"
              },
              {
                "region": "canton_zug",
                "url": "https://www.zg.ch/behoerden/gesundheitsdirektion/amt-fuer-gesundheit/corona"
              },
              {
                "region": "canton_zurich",
                "url": "https://www.zh.ch/de/gesundheit/coronavirus.html"
              },
              {
                "region": "country_liechtenstein",
                "url": "https://www.llv.li/inhalt/118724/amtsstellen/coronavirus"
              }
            ],
            "pt": [
              {
                "region": "canton_aargau",
                "url": "https://www.ag.ch/de/themen_1/coronavirus_2/coronavirus.jsp"
              },
              {
                "region": "canton_appenzell_ausserrhoden",
                "url": "https://www.ar.ch/verwaltung/departement-gesundheit-und-soziales/amt-fuer-gesundheit/informationsseite-coronavirus/"
              },
              {
                "region": "canton_appenzell_innerrhoden",
                "url": "https://www.ai.ch/themen/gesundheit-alter-und-soziales/gesundheitsfoerderung-und-praevention/uebertragbare-krankheiten/coronavirus"
              },
              {
                "region": "canton_basel_country",
                "url": "https://www.baselland.ch/politik-und-behorden/direktionen/volkswirtschafts-und-gesundheitsdirektion/amt-fur-gesundheit/medizinische-dienste/kantonsarztlicher-dienst/aktuelles"
              },
              {
                "region": "canton_basel_city",
                "url": "https://www.coronavirus.bs.ch/"
              },
              {
                "region": "canton_berne",
                "url": "http://www.be.ch/corona"
              },
              {
                "region": "canton_fribourg",
                "url": "https://www.fr.ch/sante/covid-19/coronavirus-informations-actuelles-toutes-les-actualites-liees-au-covid-19-mesures-prises-faq-statistiques"
              },
              {
                "region": "canton_geneva",
                "url": "https://www.ge.ch/pt-pt/covid-19-o-essencial-em-detalhe"
              },
              {
                "region": "canton_glarus",
                "url": "https://www.gl.ch/verwaltung/finanzen-und-gesundheit/gesundheit/coronavirus.html/4817"
              },
              {
                "region": "canton_graubuenden",
                "url": "https://www.gr.ch/DE/institutionen/verwaltung/djsg/ga/coronavirus/info/Seiten/Start.aspx"
              },
              {
                "region": "canton_jura",
                "url": "https://www.jura.ch/fr/Autorites/Coronavirus/Accueil/Coronavirus-Informations-officielles-a-la-population-jurassienne.html"
              },
              {
                "region": "canton_lucerne",
                "url": "https://gesundheit.lu.ch/themen/Humanmedizin/Infektionskrankheiten/Informationen_Coronavirus"
              },
              {
                "region": "canton_neuchatel",
                "url": "https://www.ne.ch/autorites/DFS/SCSP/medecin-cantonal/maladies-vaccinations/Pages/Coronavirus.aspx"
              },
              {
                "region": "canton_nidwalden",
                "url": "https://www.nw.ch/gesundheitsamtdienste/6044"
              },
              {
                "region": "canton_obwalden",
                "url": "https://www.ow.ch/de/verwaltung/dienstleistungen/?dienst_id=5962"
              },
              {
                "region": "canton_st_gallen",
                "url": "https://www.sg.ch/tools/informationen-coronavirus.html"
              },
              {
                "region": "canton_schaffhausen",
                "url": "https://sh.ch/CMS/Webseite/Kanton-Schaffhausen/Beh-rde/Verwaltung/Departement-des-Innern/Gesundheitsamt-2954701-DE.html"
              },
              {
                "region": "canton_schwyz",
                "url": "https://www.sz.ch/behoerden/information-medien/medienmitteilungen/coronavirus.html/72-416-412-1379-6948"
              },
              {
                "region": "canton_solothurn",
                "url": "https://corona.so.ch/"
              },
              {
                "region": "canton_thurgovia",
                "url": "https://www.tg.ch/news/fachdossier-coronavirus.html/10552"
              },
              {
                "region": "canton_ticino",
                "url": "https://www4.ti.ch/dss/dsp/covid19/home/"
              },
              {
                "region": "canton_uri",
                "url": "https://www.ur.ch/themen/2962"
              },
              {
                "region": "canton_valais",
                "url": "https://www.vs.ch/web/coronavirus/"
              },
              {
                "region": "canton_vaud",
                "url": "https://www.vd.ch/toutes-les-actualites/hotline-et-informations-sur-le-coronavirus/"
              },
              {
                "region": "canton_zug",
                "url": "https://www.zg.ch/behoerden/gesundheitsdirektion/amt-fuer-gesundheit/corona"
              },
              {
                "region": "canton_zurich",
                "url": "https://www.zh.ch/de/gesundheit/coronavirus.html"
              },
              {
                "region": "country_liechtenstein",
                "url": "https://www.llv.li/inhalt/118724/amtsstellen/coronavirus"
              }
            ],
            "es": [
              {
                "region": "canton_aargau",
                "url": "https://www.ag.ch/de/themen_1/coronavirus_2/coronavirus.jsp"
              },
              {
                "region": "canton_appenzell_ausserrhoden",
                "url": "https://www.ar.ch/verwaltung/departement-gesundheit-und-soziales/amt-fuer-gesundheit/informationsseite-coronavirus/"
              },
              {
                "region": "canton_appenzell_innerrhoden",
                "url": "https://www.ai.ch/themen/gesundheit-alter-und-soziales/gesundheitsfoerderung-und-praevention/uebertragbare-krankheiten/coronavirus"
              },
              {
                "region": "canton_basel_country",
                "url": "https://www.baselland.ch/politik-und-behorden/direktionen/volkswirtschafts-und-gesundheitsdirektion/amt-fur-gesundheit/medizinische-dienste/kantonsarztlicher-dienst/aktuelles"
              },
              {
                "region": "canton_basel_city",
                "url": "https://www.coronavirus.bs.ch/"
              },
              {
                "region": "canton_berne",
                "url": "http://www.be.ch/corona"
              },
              {
                "region": "canton_fribourg",
                "url": "https://www.fr.ch/sante/covid-19/coronavirus-informations-actuelles-toutes-les-actualites-liees-au-covid-19-mesures-prises-faq-statistiques"
              },
              {
                "region": "canton_geneva",
                "url": "https://www.ge.ch/es/protegerse-si-mismo-los-demas-personas"
              },
              {
                "region": "canton_glarus",
                "url": "https://www.gl.ch/verwaltung/finanzen-und-gesundheit/gesundheit/coronavirus.html/4817"
              },
              {
                "region": "canton_graubuenden",
                "url": "https://www.gr.ch/DE/institutionen/verwaltung/djsg/ga/coronavirus/info/Seiten/Start.aspx"
              },
              {
                "region": "canton_jura",
                "url": "https://www.jura.ch/fr/Autorites/Coronavirus/Accueil/Coronavirus-Informations-officielles-a-la-population-jurassienne.html"
              },
              {
                "region": "canton_lucerne",
                "url": "https://gesundheit.lu.ch/themen/Humanmedizin/Infektionskrankheiten/Informationen_Coronavirus"
              },
              {
                "region": "canton_neuchatel",
                "url": "https://www.ne.ch/autorites/DFS/SCSP/medecin-cantonal/maladies-vaccinations/Pages/Coronavirus.aspx"
              },
              {
                "region": "canton_nidwalden",
                "url": "https://www.nw.ch/gesundheitsamtdienste/6044"
              },
              {
                "region": "canton_obwalden",
                "url": "https://www.ow.ch/de/verwaltung/dienstleistungen/?dienst_id=5962"
              },
              {
                "region": "canton_st_gallen",
                "url": "https://www.sg.ch/tools/informationen-coronavirus.html"
              },
              {
                "region": "canton_schaffhausen",
                "url": "https://sh.ch/CMS/Webseite/Kanton-Schaffhausen/Beh-rde/Verwaltung/Departement-des-Innern/Gesundheitsamt-2954701-DE.html"
              },
              {
                "region": "canton_schwyz",
                "url": "https://www.sz.ch/behoerden/information-medien/medienmitteilungen/coronavirus.html/72-416-412-1379-6948"
              },
              {
                "region": "canton_solothurn",
                "url": "https://corona.so.ch/"
              },
              {
                "region": "canton_thurgovia",
                "url": "https://www.tg.ch/news/fachdossier-coronavirus.html/10552"
              },
              {
                "region": "canton_ticino",
                "url": "https://www4.ti.ch/dss/dsp/covid19/home/"
              },
              {
                "region": "canton_uri",
                "url": "https://www.ur.ch/themen/2962"
              },
              {
                "region": "canton_valais",
                "url": "https://www.vs.ch/web/coronavirus/"
              },
              {
                "region": "canton_vaud",
                "url": "https://www.vd.ch/toutes-les-actualites/hotline-et-informations-sur-le-coronavirus/"
              },
              {
                "region": "canton_zug",
                "url": "https://www.zg.ch/behoerden/gesundheitsdirektion/amt-fuer-gesundheit/corona"
              },
              {
                "region": "canton_zurich",
                "url": "https://www.zh.ch/de/gesundheit/coronavirus.html"
              },
              {
                "region": "country_liechtenstein",
                "url": "https://www.llv.li/inhalt/118724/amtsstellen/coronavirus"
              }
            ],
            "sq": [
              {
                "region": "canton_aargau",
                "url": "https://www.ag.ch/de/themen_1/coronavirus_2/coronavirus.jsp"
              },
              {
                "region": "canton_appenzell_ausserrhoden",
                "url": "https://www.ar.ch/verwaltung/departement-gesundheit-und-soziales/amt-fuer-gesundheit/informationsseite-coronavirus/"
              },
              {
                "region": "canton_appenzell_innerrhoden",
                "url": "https://www.ai.ch/themen/gesundheit-alter-und-soziales/gesundheitsfoerderung-und-praevention/uebertragbare-krankheiten/coronavirus"
              },
              {
                "region": "canton_basel_country",
                "url": "https://www.baselland.ch/politik-und-behorden/direktionen/volkswirtschafts-und-gesundheitsdirektion/amt-fur-gesundheit/medizinische-dienste/kantonsarztlicher-dienst/aktuelles"
              },
              {
                "region": "canton_basel_city",
                "url": "https://www.coronavirus.bs.ch/"
              },
              {
                "region": "canton_berne",
                "url": "http://www.be.ch/corona"
              },
              {
                "region": "canton_fribourg",
                "url": "https://www.fr.ch/sante/covid-19/coronavirus-informations-actuelles-toutes-les-actualites-liees-au-covid-19-mesures-prises-faq-statistiques"
              },
              {
                "region": "canton_geneva",
                "url": "https://www.ge.ch/covid-19-se-proteger-proteger-autres"
              },
              {
                "region": "canton_glarus",
                "url": "https://www.gl.ch/verwaltung/finanzen-und-gesundheit/gesundheit/coronavirus.html/4817"
              },
              {
                "region": "canton_graubuenden",
                "url": "https://www.gr.ch/DE/institutionen/verwaltung/djsg/ga/coronavirus/info/Seiten/Start.aspx"
              },
              {
                "region": "canton_jura",
                "url": "https://www.jura.ch/fr/Autorites/Coronavirus/Accueil/Coronavirus-Informations-officielles-a-la-population-jurassienne.html"
              },
              {
                "region": "canton_lucerne",
                "url": "https://gesundheit.lu.ch/themen/Humanmedizin/Infektionskrankheiten/Informationen_Coronavirus"
              },
              {
                "region": "canton_neuchatel",
                "url": "https://www.ne.ch/autorites/DFS/SCSP/medecin-cantonal/maladies-vaccinations/Pages/Coronavirus.aspx"
              },
              {
                "region": "canton_nidwalden",
                "url": "https://www.nw.ch/gesundheitsamtdienste/6044"
              },
              {
                "region": "canton_obwalden",
                "url": "https://www.ow.ch/de/verwaltung/dienstleistungen/?dienst_id=5962"
              },
              {
                "region": "canton_st_gallen",
                "url": "https://www.sg.ch/tools/informationen-coronavirus.html"
              },
              {
                "region": "canton_schaffhausen",
                "url": "https://sh.ch/CMS/Webseite/Kanton-Schaffhausen/Beh-rde/Verwaltung/Departement-des-Innern/Gesundheitsamt-2954701-DE.html"
              },
              {
                "region": "canton_schwyz",
                "url": "https://www.sz.ch/behoerden/information-medien/medienmitteilungen/coronavirus.html/72-416-412-1379-6948"
              },
              {
                "region": "canton_solothurn",
                "url": "https://corona.so.ch/"
              },
              {
                "region": "canton_thurgovia",
                "url": "https://www.tg.ch/news/fachdossier-coronavirus.html/10552"
              },
              {
                "region": "canton_ticino",
                "url": "https://www4.ti.ch/dss/dsp/covid19/home/"
              },
              {
                "region": "canton_uri",
                "url": "https://www.ur.ch/themen/2962"
              },
              {
                "region": "canton_valais",
                "url": "https://www.vs.ch/web/coronavirus/"
              },
              {
                "region": "canton_vaud",
                "url": "https://www.vd.ch/toutes-les-actualites/hotline-et-informations-sur-le-coronavirus/"
              },
              {
                "region": "canton_zug",
                "url": "https://www.zg.ch/behoerden/gesundheitsdirektion/amt-fuer-gesundheit/corona"
              },
              {
                "region": "canton_zurich",
                "url": "https://www.zh.ch/de/gesundheit/coronavirus.html"
              },
              {
                "region": "country_liechtenstein",
                "url": "https://www.llv.li/inhalt/118724/amtsstellen/coronavirus"
              }
            ],
            "bs": [
              {
                "region": "canton_aargau",
                "url": "https://www.ag.ch/de/themen_1/coronavirus_2/coronavirus.jsp"
              },
              {
                "region": "canton_appenzell_ausserrhoden",
                "url": "https://www.ar.ch/verwaltung/departement-gesundheit-und-soziales/amt-fuer-gesundheit/informationsseite-coronavirus/"
              },
              {
                "region": "canton_appenzell_innerrhoden",
                "url": "https://www.ai.ch/themen/gesundheit-alter-und-soziales/gesundheitsfoerderung-und-praevention/uebertragbare-krankheiten/coronavirus"
              },
              {
                "region": "canton_basel_country",
                "url": "https://www.baselland.ch/politik-und-behorden/direktionen/volkswirtschafts-und-gesundheitsdirektion/amt-fur-gesundheit/medizinische-dienste/kantonsarztlicher-dienst/aktuelles"
              },
              {
                "region": "canton_basel_city",
                "url": "https://www.coronavirus.bs.ch/"
              },
              {
                "region": "canton_berne",
                "url": "http://www.be.ch/corona"
              },
              {
                "region": "canton_fribourg",
                "url": "https://www.fr.ch/sante/covid-19/coronavirus-informations-actuelles-toutes-les-actualites-liees-au-covid-19-mesures-prises-faq-statistiques"
              },
              {
                "region": "canton_geneva",
                "url": "https://www.ge.ch/covid-19-se-proteger-proteger-autres"
              },
              {
                "region": "canton_glarus",
                "url": "https://www.gl.ch/verwaltung/finanzen-und-gesundheit/gesundheit/coronavirus.html/4817"
              },
              {
                "region": "canton_graubuenden",
                "url": "https://www.gr.ch/DE/institutionen/verwaltung/djsg/ga/coronavirus/info/Seiten/Start.aspx"
              },
              {
                "region": "canton_jura",
                "url": "https://www.jura.ch/fr/Autorites/Coronavirus/Accueil/Coronavirus-Informations-officielles-a-la-population-jurassienne.html"
              },
              {
                "region": "canton_lucerne",
                "url": "https://gesundheit.lu.ch/themen/Humanmedizin/Infektionskrankheiten/Informationen_Coronavirus"
              },
              {
                "region": "canton_neuchatel",
                "url": "https://www.ne.ch/autorites/DFS/SCSP/medecin-cantonal/maladies-vaccinations/Pages/Coronavirus.aspx"
              },
              {
                "region": "canton_nidwalden",
                "url": "https://www.nw.ch/gesundheitsamtdienste/6044"
              },
              {
                "region": "canton_obwalden",
                "url": "https://www.ow.ch/de/verwaltung/dienstleistungen/?dienst_id=5962"
              },
              {
                "region": "canton_st_gallen",
                "url": "https://www.sg.ch/tools/informationen-coronavirus.html"
              },
              {
                "region": "canton_schaffhausen",
                "url": "https://sh.ch/CMS/Webseite/Kanton-Schaffhausen/Beh-rde/Verwaltung/Departement-des-Innern/Gesundheitsamt-2954701-DE.html"
              },
              {
                "region": "canton_schwyz",
                "url": "https://www.sz.ch/behoerden/information-medien/medienmitteilungen/coronavirus.html/72-416-412-1379-6948"
              },
              {
                "region": "canton_solothurn",
                "url": "https://corona.so.ch/"
              },
              {
                "region": "canton_thurgovia",
                "url": "https://www.tg.ch/news/fachdossier-coronavirus.html/10552"
              },
              {
                "region": "canton_ticino",
                "url": "https://www4.ti.ch/dss/dsp/covid19/home/"
              },
              {
                "region": "canton_uri",
                "url": "https://www.ur.ch/themen/2962"
              },
              {
                "region": "canton_valais",
                "url": "https://www.vs.ch/web/coronavirus/"
              },
              {
                "region": "canton_vaud",
                "url": "https://www.vd.ch/toutes-les-actualites/hotline-et-informations-sur-le-coronavirus/"
              },
              {
                "region": "canton_zug",
                "url": "https://www.zg.ch/behoerden/gesundheitsdirektion/amt-fuer-gesundheit/corona"
              },
              {
                "region": "canton_zurich",
                "url": "https://www.zh.ch/de/gesundheit/coronavirus.html"
              },
              {
                "region": "country_liechtenstein",
                "url": "https://www.llv.li/inhalt/118724/amtsstellen/coronavirus"
              }
            ],
            "hr": [
              {
                "region": "canton_aargau",
                "url": "https://www.ag.ch/de/themen_1/coronavirus_2/coronavirus.jsp"
              },
              {
                "region": "canton_appenzell_ausserrhoden",
                "url": "https://www.ar.ch/verwaltung/departement-gesundheit-und-soziales/amt-fuer-gesundheit/informationsseite-coronavirus/"
              },
              {
                "region": "canton_appenzell_innerrhoden",
                "url": "https://www.ai.ch/themen/gesundheit-alter-und-soziales/gesundheitsfoerderung-und-praevention/uebertragbare-krankheiten/coronavirus"
              },
              {
                "region": "canton_basel_country",
                "url": "https://www.baselland.ch/politik-und-behorden/direktionen/volkswirtschafts-und-gesundheitsdirektion/amt-fur-gesundheit/medizinische-dienste/kantonsarztlicher-dienst/aktuelles"
              },
              {
                "region": "canton_basel_city",
                "url": "https://www.coronavirus.bs.ch/"
              },
              {
                "region": "canton_berne",
                "url": "http://www.be.ch/corona"
              },
              {
                "region": "canton_fribourg",
                "url": "https://www.fr.ch/sante/covid-19/coronavirus-informations-actuelles-toutes-les-actualites-liees-au-covid-19-mesures-prises-faq-statistiques"
              },
              {
                "region": "canton_geneva",
                "url": "https://www.ge.ch/covid-19-se-proteger-proteger-autres"
              },
              {
                "region": "canton_glarus",
                "url": "https://www.gl.ch/verwaltung/finanzen-und-gesundheit/gesundheit/coronavirus.html/4817"
              },
              {
                "region": "canton_graubuenden",
                "url": "https://www.gr.ch/DE/institutionen/verwaltung/djsg/ga/coronavirus/info/Seiten/Start.aspx"
              },
              {
                "region": "canton_jura",
                "url": "https://www.jura.ch/fr/Autorites/Coronavirus/Accueil/Coronavirus-Informations-officielles-a-la-population-jurassienne.html"
              },
              {
                "region": "canton_lucerne",
                "url": "https://gesundheit.lu.ch/themen/Humanmedizin/Infektionskrankheiten/Informationen_Coronavirus"
              },
              {
                "region": "canton_neuchatel",
                "url": "https://www.ne.ch/autorites/DFS/SCSP/medecin-cantonal/maladies-vaccinations/Pages/Coronavirus.aspx"
              },
              {
                "region": "canton_nidwalden",
                "url": "https://www.nw.ch/gesundheitsamtdienste/6044"
              },
              {
                "region": "canton_obwalden",
                "url": "https://www.ow.ch/de/verwaltung/dienstleistungen/?dienst_id=5962"
              },
              {
                "region": "canton_st_gallen",
                "url": "https://www.sg.ch/tools/informationen-coronavirus.html"
              },
              {
                "region": "canton_schaffhausen",
                "url": "https://sh.ch/CMS/Webseite/Kanton-Schaffhausen/Beh-rde/Verwaltung/Departement-des-Innern/Gesundheitsamt-2954701-DE.html"
              },
              {
                "region": "canton_schwyz",
                "url": "https://www.sz.ch/behoerden/information-medien/medienmitteilungen/coronavirus.html/72-416-412-1379-6948"
              },
              {
                "region": "canton_solothurn",
                "url": "https://corona.so.ch/"
              },
              {
                "region": "canton_thurgovia",
                "url": "https://www.tg.ch/news/fachdossier-coronavirus.html/10552"
              },
              {
                "region": "canton_ticino",
                "url": "https://www4.ti.ch/dss/dsp/covid19/home/"
              },
              {
                "region": "canton_uri",
                "url": "https://www.ur.ch/themen/2962"
              },
              {
                "region": "canton_valais",
                "url": "https://www.vs.ch/web/coronavirus/"
              },
              {
                "region": "canton_vaud",
                "url": "https://www.vd.ch/toutes-les-actualites/hotline-et-informations-sur-le-coronavirus/"
              },
              {
                "region": "canton_zug",
                "url": "https://www.zg.ch/behoerden/gesundheitsdirektion/amt-fuer-gesundheit/corona"
              },
              {
                "region": "canton_zurich",
                "url": "https://www.zh.ch/de/gesundheit/coronavirus.html"
              },
              {
                "region": "country_liechtenstein",
                "url": "https://www.llv.li/inhalt/118724/amtsstellen/coronavirus"
              }
            ],
            "sr": [
              {
                "region": "canton_aargau",
                "url": "https://www.ag.ch/de/themen_1/coronavirus_2/coronavirus.jsp"
              },
              {
                "region": "canton_appenzell_ausserrhoden",
                "url": "https://www.ar.ch/verwaltung/departement-gesundheit-und-soziales/amt-fuer-gesundheit/informationsseite-coronavirus/"
              },
              {
                "region": "canton_appenzell_innerrhoden",
                "url": "https://www.ai.ch/themen/gesundheit-alter-und-soziales/gesundheitsfoerderung-und-praevention/uebertragbare-krankheiten/coronavirus"
              },
              {
                "region": "canton_basel_country",
                "url": "https://www.baselland.ch/politik-und-behorden/direktionen/volkswirtschafts-und-gesundheitsdirektion/amt-fur-gesundheit/medizinische-dienste/kantonsarztlicher-dienst/aktuelles"
              },
              {
                "region": "canton_basel_city",
                "url": "https://www.coronavirus.bs.ch/"
              },
              {
                "region": "canton_berne",
                "url": "http://www.be.ch/corona"
              },
              {
                "region": "canton_fribourg",
                "url": "https://www.fr.ch/sante/covid-19/coronavirus-informations-actuelles-toutes-les-actualites-liees-au-covid-19-mesures-prises-faq-statistiques"
              },
              {
                "region": "canton_geneva",
                "url": "https://www.ge.ch/covid-19-se-proteger-proteger-autres"
              },
              {
                "region": "canton_glarus",
                "url": "https://www.gl.ch/verwaltung/finanzen-und-gesundheit/gesundheit/coronavirus.html/4817"
              },
              {
                "region": "canton_graubuenden",
                "url": "https://www.gr.ch/DE/institutionen/verwaltung/djsg/ga/coronavirus/info/Seiten/Start.aspx"
              },
              {
                "region": "canton_jura",
                "url": "https://www.jura.ch/fr/Autorites/Coronavirus/Accueil/Coronavirus-Informations-officielles-a-la-population-jurassienne.html"
              },
              {
                "region": "canton_lucerne",
                "url": "https://gesundheit.lu.ch/themen/Humanmedizin/Infektionskrankheiten/Informationen_Coronavirus"
              },
              {
                "region": "canton_neuchatel",
                "url": "https://www.ne.ch/autorites/DFS/SCSP/medecin-cantonal/maladies-vaccinations/Pages/Coronavirus.aspx"
              },
              {
                "region": "canton_nidwalden",
                "url": "https://www.nw.ch/gesundheitsamtdienste/6044"
              },
              {
                "region": "canton_obwalden",
                "url": "https://www.ow.ch/de/verwaltung/dienstleistungen/?dienst_id=5962"
              },
              {
                "region": "canton_st_gallen",
                "url": "https://www.sg.ch/tools/informationen-coronavirus.html"
              },
              {
                "region": "canton_schaffhausen",
                "url": "https://sh.ch/CMS/Webseite/Kanton-Schaffhausen/Beh-rde/Verwaltung/Departement-des-Innern/Gesundheitsamt-2954701-DE.html"
              },
              {
                "region": "canton_schwyz",
                "url": "https://www.sz.ch/behoerden/information-medien/medienmitteilungen/coronavirus.html/72-416-412-1379-6948"
              },
              {
                "region": "canton_solothurn",
                "url": "https://corona.so.ch/"
              },
              {
                "region": "canton_thurgovia",
                "url": "https://www.tg.ch/news/fachdossier-coronavirus.html/10552"
              },
              {
                "region": "canton_ticino",
                "url": "https://www4.ti.ch/dss/dsp/covid19/home/"
              },
              {
                "region": "canton_uri",
                "url": "https://www.ur.ch/themen/2962"
              },
              {
                "region": "canton_valais",
                "url": "https://www.vs.ch/web/coronavirus/"
              },
              {
                "region": "canton_vaud",
                "url": "https://www.vd.ch/toutes-les-actualites/hotline-et-informations-sur-le-coronavirus/"
              },
              {
                "region": "canton_zug",
                "url": "https://www.zg.ch/behoerden/gesundheitsdirektion/amt-fuer-gesundheit/corona"
              },
              {
                "region": "canton_zurich",
                "url": "https://www.zh.ch/de/gesundheit/coronavirus.html"
              },
              {
                "region": "country_liechtenstein",
                "url": "https://www.llv.li/inhalt/118724/amtsstellen/coronavirus"
              }
            ],
            "rm": [
              {
                "region": "canton_aargau",
                "url": "https://www.ag.ch/de/themen_1/coronavirus_2/coronavirus.jsp"
              },
              {
                "region": "canton_appenzell_ausserrhoden",
                "url": "https://www.ar.ch/verwaltung/departement-gesundheit-und-soziales/amt-fuer-gesundheit/informationsseite-coronavirus/"
              },
              {
                "region": "canton_appenzell_innerrhoden",
                "url": "https://www.ai.ch/themen/gesundheit-alter-und-soziales/gesundheitsfoerderung-und-praevention/uebertragbare-krankheiten/coronavirus"
              },
              {
                "region": "canton_basel_country",
                "url": "https://www.baselland.ch/politik-und-behorden/direktionen/volkswirtschafts-und-gesundheitsdirektion/amt-fur-gesundheit/medizinische-dienste/kantonsarztlicher-dienst/aktuelles"
              },
              {
                "region": "canton_basel_city",
                "url": "https://www.coronavirus.bs.ch/"
              },
              {
                "region": "canton_berne",
                "url": "http://www.be.ch/corona"
              },
              {
                "region": "canton_fribourg",
                "url": "https://www.fr.ch/sante/covid-19/coronavirus-informations-actuelles-toutes-les-actualites-liees-au-covid-19-mesures-prises-faq-statistiques"
              },
              {
                "region": "canton_geneva",
                "url": "https://www.ge.ch/covid-19-se-proteger-proteger-autres"
              },
              {
                "region": "canton_glarus",
                "url": "https://www.gl.ch/verwaltung/finanzen-und-gesundheit/gesundheit/coronavirus.html/4817"
              },
              {
                "region": "canton_graubuenden",
                "url": "https://www.gr.ch/RM/instituziuns/administraziun/djsg/ga/coronavirus/info/Seiten/Start.aspx"
              },
              {
                "region": "canton_jura",
                "url": "https://www.jura.ch/fr/Autorites/Coronavirus/Accueil/Coronavirus-Informations-officielles-a-la-population-jurassienne.html"
              },
              {
                "region": "canton_lucerne",
                "url": "https://gesundheit.lu.ch/themen/Humanmedizin/Infektionskrankheiten/Informationen_Coronavirus"
              },
              {
                "region": "canton_neuchatel",
                "url": "https://www.ne.ch/autorites/DFS/SCSP/medecin-cantonal/maladies-vaccinations/Pages/Coronavirus.aspx"
              },
              {
                "region": "canton_nidwalden",
                "url": "https://www.nw.ch/gesundheitsamtdienste/6044"
              },
              {
                "region": "canton_obwalden",
                "url": "https://www.ow.ch/de/verwaltung/dienstleistungen/?dienst_id=5962"
              },
              {
                "region": "canton_st_gallen",
                "url": "https://www.sg.ch/tools/informationen-coronavirus.html"
              },
              {
                "region": "canton_schaffhausen",
                "url": "https://sh.ch/CMS/Webseite/Kanton-Schaffhausen/Beh-rde/Verwaltung/Departement-des-Innern/Gesundheitsamt-2954701-DE.html"
              },
              {
                "region": "canton_schwyz",
                "url": "https://www.sz.ch/behoerden/information-medien/medienmitteilungen/coronavirus.html/72-416-412-1379-6948"
              },
              {
                "region": "canton_solothurn",
                "url": "https://corona.so.ch/"
              },
              {
                "region": "canton_thurgovia",
                "url": "https://www.tg.ch/news/fachdossier-coronavirus.html/10552"
              },
              {
                "region": "canton_ticino",
                "url": "https://www4.ti.ch/dss/dsp/covid19/home/"
              },
              {
                "region": "canton_uri",
                "url": "https://www.ur.ch/themen/2962"
              },
              {
                "region": "canton_valais",
                "url": "https://www.vs.ch/web/coronavirus/"
              },
              {
                "region": "canton_vaud",
                "url": "https://www.vd.ch/toutes-les-actualites/hotline-et-informations-sur-le-coronavirus/"
              },
              {
                "region": "canton_zug",
                "url": "https://www.zg.ch/behoerden/gesundheitsdirektion/amt-fuer-gesundheit/corona"
              },
              {
                "region": "canton_zurich",
                "url": "https://www.zh.ch/de/gesundheit/coronavirus.html"
              },
              {
                "region": "country_liechtenstein",
                "url": "https://www.llv.li/inhalt/118724/amtsstellen/coronavirus"
              }
            ],
            "tr": [
              {
                "region": "canton_aargau",
                "url": "https://www.ag.ch/de/themen_1/coronavirus_2/coronavirus.jsp"
              },
              {
                "region": "canton_appenzell_ausserrhoden",
                "url": "https://www.ar.ch/verwaltung/departement-gesundheit-und-soziales/amt-fuer-gesundheit/informationsseite-coronavirus/"
              },
              {
                "region": "canton_appenzell_innerrhoden",
                "url": "https://www.ai.ch/themen/gesundheit-alter-und-soziales/gesundheitsfoerderung-und-praevention/uebertragbare-krankheiten/coronavirus"
              },
              {
                "region": "canton_basel_country",
                "url": "https://www.baselland.ch/politik-und-behorden/direktionen/volkswirtschafts-und-gesundheitsdirektion/amt-fur-gesundheit/medizinische-dienste/kantonsarztlicher-dienst/aktuelles"
              },
              {
                "region": "canton_basel_city",
                "url": "https://www.coronavirus.bs.ch/"
              },
              {
                "region": "canton_berne",
                "url": "http://www.be.ch/corona"
              },
              {
                "region": "canton_fribourg",
                "url": "https://www.fr.ch/sante/covid-19/coronavirus-informations-actuelles-toutes-les-actualites-liees-au-covid-19-mesures-prises-faq-statistiques"
              },
              {
                "region": "canton_geneva",
                "url": "https://www.ge.ch/covid-19-se-proteger-proteger-autres"
              },
              {
                "region": "canton_glarus",
                "url": "https://www.gl.ch/verwaltung/finanzen-und-gesundheit/gesundheit/coronavirus.html/4817"
              },
              {
                "region": "canton_graubuenden",
                "url": "https://www.gr.ch/DE/institutionen/verwaltung/djsg/ga/coronavirus/info/Seiten/Start.aspx"
              },
              {
                "region": "canton_jura",
                "url": "https://www.jura.ch/fr/Autorites/Coronavirus/Accueil/Coronavirus-Informations-officielles-a-la-population-jurassienne.html"
              },
              {
                "region": "canton_lucerne",
                "url": "https://gesundheit.lu.ch/themen/Humanmedizin/Infektionskrankheiten/Informationen_Coronavirus"
              },
              {
                "region": "canton_neuchatel",
                "url": "https://www.ne.ch/autorites/DFS/SCSP/medecin-cantonal/maladies-vaccinations/Pages/Coronavirus.aspx"
              },
              {
                "region": "canton_nidwalden",
                "url": "https://www.nw.ch/gesundheitsamtdienste/6044"
              },
              {
                "region": "canton_obwalden",
                "url": "https://www.ow.ch/de/verwaltung/dienstleistungen/?dienst_id=5962"
              },
              {
                "region": "canton_st_gallen",
                "url": "https://www.sg.ch/tools/informationen-coronavirus.html"
              },
              {
                "region": "canton_schaffhausen",
                "url": "https://sh.ch/CMS/Webseite/Kanton-Schaffhausen/Beh-rde/Verwaltung/Departement-des-Innern/Gesundheitsamt-2954701-DE.html"
              },
              {
                "region": "canton_schwyz",
                "url": "https://www.sz.ch/behoerden/information-medien/medienmitteilungen/coronavirus.html/72-416-412-1379-6948"
              },
              {
                "region": "canton_solothurn",
                "url": "https://corona.so.ch/"
              },
              {
                "region": "canton_thurgovia",
                "url": "https://www.tg.ch/news/fachdossier-coronavirus.html/10552"
              },
              {
                "region": "canton_ticino",
                "url": "https://www4.ti.ch/dss/dsp/covid19/home/"
              },
              {
                "region": "canton_uri",
                "url": "https://www.ur.ch/themen/2962"
              },
              {
                "region": "canton_valais",
                "url": "https://www.vs.ch/web/coronavirus/"
              },
              {
                "region": "canton_vaud",
                "url": "https://www.vd.ch/toutes-les-actualites/hotline-et-informations-sur-le-coronavirus/"
              },
              {
                "region": "canton_zug",
                "url": "https://www.zg.ch/behoerden/gesundheitsdirektion/amt-fuer-gesundheit/corona"
              },
              {
                "region": "canton_zurich",
                "url": "https://www.zh.ch/de/gesundheit/coronavirus.html"
              },
              {
                "region": "country_liechtenstein",
                "url": "https://www.llv.li/inhalt/118724/amtsstellen/coronavirus"
              }
            ],
            "ti": [
              {
                "region": "canton_aargau",
                "url": "https://www.ag.ch/de/themen_1/coronavirus_2/coronavirus.jsp"
              },
              {
                "region": "canton_appenzell_ausserrhoden",
                "url": "https://www.ar.ch/verwaltung/departement-gesundheit-und-soziales/amt-fuer-gesundheit/informationsseite-coronavirus/"
              },
              {
                "region": "canton_appenzell_innerrhoden",
                "url": "https://www.ai.ch/themen/gesundheit-alter-und-soziales/gesundheitsfoerderung-und-praevention/uebertragbare-krankheiten/coronavirus"
              },
              {
                "region": "canton_basel_country",
                "url": "https://www.baselland.ch/politik-und-behorden/direktionen/volkswirtschafts-und-gesundheitsdirektion/amt-fur-gesundheit/medizinische-dienste/kantonsarztlicher-dienst/aktuelles"
              },
              {
                "region": "canton_basel_city",
                "url": "https://www.coronavirus.bs.ch/"
              },
              {
                "region": "canton_berne",
                "url": "http://www.be.ch/corona"
              },
              {
                "region": "canton_fribourg",
                "url": "https://www.fr.ch/sante/covid-19/coronavirus-informations-actuelles-toutes-les-actualites-liees-au-covid-19-mesures-prises-faq-statistiques"
              },
              {
                "region": "canton_geneva",
                "url": "https://www.ge.ch/covid-19-se-proteger-proteger-autres"
              },
              {
                "region": "canton_glarus",
                "url": "https://www.gl.ch/verwaltung/finanzen-und-gesundheit/gesundheit/coronavirus.html/4817"
              },
              {
                "region": "canton_graubuenden",
                "url": "https://www.gr.ch/DE/institutionen/verwaltung/djsg/ga/coronavirus/info/Seiten/Start.aspx"
              },
              {
                "region": "canton_jura",
                "url": "https://www.jura.ch/fr/Autorites/Coronavirus/Accueil/Coronavirus-Informations-officielles-a-la-population-jurassienne.html"
              },
              {
                "region": "canton_lucerne",
                "url": "https://gesundheit.lu.ch/themen/Humanmedizin/Infektionskrankheiten/Informationen_Coronavirus"
              },
              {
                "region": "canton_neuchatel",
                "url": "https://www.ne.ch/autorites/DFS/SCSP/medecin-cantonal/maladies-vaccinations/Pages/Coronavirus.aspx"
              },
              {
                "region": "canton_nidwalden",
                "url": "https://www.nw.ch/gesundheitsamtdienste/6044"
              },
              {
                "region": "canton_obwalden",
                "url": "https://www.ow.ch/de/verwaltung/dienstleistungen/?dienst_id=5962"
              },
              {
                "region": "canton_st_gallen",
                "url": "https://www.sg.ch/tools/informationen-coronavirus.html"
              },
              {
                "region": "canton_schaffhausen",
                "url": "https://sh.ch/CMS/Webseite/Kanton-Schaffhausen/Beh-rde/Verwaltung/Departement-des-Innern/Gesundheitsamt-2954701-DE.html"
              },
              {
                "region": "canton_schwyz",
                "url": "https://www.sz.ch/behoerden/information-medien/medienmitteilungen/coronavirus.html/72-416-412-1379-6948"
              },
              {
                "region": "canton_solothurn",
                "url": "https://corona.so.ch/"
              },
              {
                "region": "canton_thurgovia",
                "url": "https://www.tg.ch/news/fachdossier-coronavirus.html/10552"
              },
              {
                "region": "canton_ticino",
                "url": "https://www4.ti.ch/dss/dsp/covid19/home/"
              },
              {
                "region": "canton_uri",
                "url": "https://www.ur.ch/themen/2962"
              },
              {
                "region": "canton_valais",
                "url": "https://www.vs.ch/web/coronavirus/"
              },
              {
                "region": "canton_vaud",
                "url": "https://www.vd.ch/toutes-les-actualites/hotline-et-informations-sur-le-coronavirus/"
              },
              {
                "region": "canton_zug",
                "url": "https://www.zg.ch/behoerden/gesundheitsdirektion/amt-fuer-gesundheit/corona"
              },
              {
                "region": "canton_zurich",
                "url": "https://www.zh.ch/de/gesundheit/coronavirus.html"
              },
              {
                "region": "country_liechtenstein",
                "url": "https://www.llv.li/inhalt/118724/amtsstellen/coronavirus"
              }
            ]
          }
        """
        if let object = try? JSONDecoder().decode(LocalizedValue<[ConfigResponseBody.TestLocation]>.self, from: json.data(using: .utf8)!) {
            return object
        } else {
            fatalError()
        }
    }
}
