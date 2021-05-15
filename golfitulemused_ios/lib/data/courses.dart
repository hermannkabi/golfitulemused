import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GolfCourse{
  final String name;
  final int par;
  final List<int> distance;
  final Map<int, List> holes;
  //holes näeb välja selline: {1:[4, 300, [59.32, 24.31]], 2:[3, 160]} ehk võti on raja number ja väärtus raja par ja pikkus (3. parameeter võib olla loend koordinaatidega).
  final List<String> maps;
  final String description;
  final String image;
  final String weather;
  final List<Color> teeColors;
  final List<String> tees;
  final Map<List<String>, Widget>contactUs;
  final bool locationEnabled;
  final List<double>location;


  GolfCourse({this.name, this.par, this.distance, this.holes, this.description, this.image, this.weather, this.tees, this.teeColors, this.maps, this.contactUs, this.locationEnabled = false, this.location = const <double>[0.0,0.0]});
}


const mapsLink = "https://maps.apple.com/?q=";
const instagramLink = "https://instagram.com/";
const facebookLink = "https://facebook.com/";


//Originally, img.techpowerup.org/200724/niitvalja-park-1.png jne.
const courseLink = "https://hermannkabi.com/assets/";


class Courses{

  //TODO: Add location to every course and hole

  List<GolfCourse> courses = [

    GolfCourse(
      locationEnabled: true,
      name: "Niitvälja Golf (PARK)",
      location: [59.317958, 24.316964],
      par: 72,
      distance: [5100, 5402,5854, 6411],
      tees: ["Punased tiid", "Sinised tiid", "Kollased tiid", "Valged tiid"],
      teeColors: [Colors.red, Colors.blue, Colors.yellow, Colors.white],
      holes: {
        1:[4, [293, 323, 335, 368], [59.317412, 24.309143]],
        2:[3, [130, 149, 155, 181], [59.316173, 24.311907]],
        3: [4, [289, 298,333, 368], [59.316545, 24.305243]],
        4: [5, [381, 423,445, 478], [59.317303, 24.296295]],
        5: [4, [300, 300,343, 379], [59.316928, 24.303208]],
        6: [3, [128, 121,129, 153], [59.317191, 24.306957]],
        7: [4, [316, 330,363, 397], [59.318658, 24.300810]],
        8: [4, [282, 322,322, 356], [59.321970, 24.302280]],
        9: [5, [383, 387,433, 485], [59.319387, 24.311933]],


        10:[4, [311, 311,359, 391], [59.319976, 24.305147]],
        11:[3, [148, 148,157, 166], [59.320222, 24.307459]],
        12: [4, [261, 294,294, 338], [59.322024, 24.303339]],
        13: [3, [119, 123,145, 158], [59.321566, 24.299163]],
        14: [4, [344, 344,386, 426], [59.318385, 24.295192]],
        15: [5, [403, 469,469, 483], [59.320731, 24.298791]],
        16: [4, [324, 324,378, 401], [59.318524, 24.299204]],
        17: [5, [402, 407,458, 509], [59.318527, 24.309220]],
        18: [4, [291, 329,340, 374], [59.317966, 24.315395]],
      },
      maps: [
        "${courseLink}niitvalja-park-1.png",
        "${courseLink}niitvalja-park-2.png",
        "${courseLink}niitvalja-park-3.png",
        "${courseLink}niitvalja-park-4.png",
        "${courseLink}niitvalja-park-5.png",
        "${courseLink}niitvalja-park-6.png",
        "${courseLink}niitvalja-park-7.png",
        "${courseLink}niitvalja-park-8.png",
        "${courseLink}niitvalja-park-9.png",

        "${courseLink}niitvalja-park-10.png",
        "${courseLink}niitvalja-park-11.png",
        "${courseLink}niitvalja-park-12.png",
        "${courseLink}niitvalja-park-13.png",
        "${courseLink}niitvalja-park-14.png",
        "${courseLink}niitvalja-park-15.png",
        "${courseLink}niitvalja-park-16.png",
        "${courseLink}niitvalja-park-17.png",
        "${courseLink}niitvalja-park-18.png",
      ],
      image: "https://niitvaljagolf.ee/wp-content/uploads/2018/03/20171018_Niit%C3%A4lja_Golf_Course_JM_018-copy-e1570566199161.jpg",
      weather: "Niitvälja",
      description: "Tallinnast ainult 30 kilomeetri kaugusel asuv väljak on kujunenud aastatega Eesti golfi sünonüümiks. Golfimängijate poolt valitud Eesti parimaks golfikeskuseks.",
      contactUs: {
        ["Telefon", "tel:3726780454"]:Icon(Icons.phone_in_talk),
        ["E-post", "mailto:info@niitvaljagolf.ee"]:Icon(Icons.email),
        ["Veebileht", "https://niitvaljagolf.ee/"]: FaIcon(FontAwesomeIcons.globe),
        ["Instagram", "${instagramLink}niitvaljagolf"]:FaIcon(FontAwesomeIcons.instagram),
        ["Facebook", "${facebookLink}golfikeskus/"]:FaIcon(FontAwesomeIcons.facebook),
      },
    ),
    GolfCourse(
      locationEnabled: true,
      name: "Niitvälja Golf (PAR20)",
      location: [59.317958, 24.316964],
      par: 20,
      distance: [1405, 1567, 1723],
      teeColors: [Colors.red, Colors.yellow, Colors.white],
      tees: ["Punased tiid", "Kollased tiid", "Valged tiid"],
      holes: {
        1:[4, [286, 321, 349], [59.320887, 24.311664]],
        2:[3, [138, 149, 160], [59.321872, 24.313069]],
        3:[4, [315, 351, 379], [59.321910, 24.306406]],
        4:[5, [400, 446, 496], [59.322934, 24.313069]],
        5:[4, [266, 300, 339], [59.318715, 24.315899]],
      },
      maps: [
        "${courseLink}niitvalja-par20-1.png",
        "${courseLink}niitvalja-par20-2.png",
        "${courseLink}niitvalja-par20-3.png",
        "${courseLink}niitvalja-par20-4.png",
        "${courseLink}niitvalja-par20-5.png"
      ],
      image: "https://niitvaljagolf.ee/wp-content/uploads/2018/03/20171018_Niit%C3%A4lja_Golf_Course_JM_031-copy-e1570566105222.jpg",
      weather: "Niitvälja",
      description: "Lisaks tipptasemel Park-väljakule on Niitväljal algajatele ja treenijatele mõeldud viierajaline pay and play-väljak, kust leiab kolm PAR4, ühe PAR3 ja ühe PAR5-raja. See on ideaalne paik golfimänguga tutvumiseks. ",
      contactUs: {
        ["Telefon", "tel:3726780454"]:Icon(Icons.phone_in_talk),
        ["E-post", "mailto:info@niitvaljagolf.ee"]:Icon(Icons.email),
        ["Veebileht", "https://niitvaljagolf.ee/"]: FaIcon(FontAwesomeIcons.globe),
        ["Instagram", "${instagramLink}niitvaljagolf"]:FaIcon(FontAwesomeIcons.instagram),
        ["Facebook", "${facebookLink}golfikeskus/"]:FaIcon(FontAwesomeIcons.facebook),
      },
    ),

    GolfCourse(
      location: [59.307672, 24.975723],
      name: "Rae Golf",
      par: 72,
      distance: [4665, 4905 ,5285,  5650],
      tees: ["Punased tiid", "Sinised tiid", "Kollased tiid", "Valged tiid"],
      teeColors: [Colors.red, Colors.blue, Colors.yellow, Colors.white],
      holes: {

        1:[4, [235,235,235,235]],
        2:[5, [405, 405,470,475]],
        3:[4, [305, 310,360,370]],
        4:[3, [125, 140,155,175]],
        5:[4, [280, 310,320,345]],
        6:[3, [170, 175,175,205]],
        7:[4, [315, 325,350,385]],
        8:[5, [460, 460,480,480]],
        9:[4, [260, 320,345,390]],

        10:[4, [250, 255,290,300]],
        11:[5, [410, 415,465,480]],
        12:[4, [280, 320,325,335]],
        13:[4, [275, 315,325,365]],
        14:[4, [305, 305,345,370]],
        15:[3, [120, 130,130,145]],
        16:[5, [95, 95,95,95]],
        17:[4, [315, 325,355,395]],
        18:[3, [60, 65,65,105]],

      },
      image: "https://raegolf.ee/static/JM_17373-copy-1920x1280.jpg",
      weather: "Rae",
      description: "Rae Golf on Tallinna lähim golfikeskus, kus leiab tegevust nii suur kui väike. Meie juurde oled oodatud kogu perega, sest tegevust jagub kõigile. Rae Golfikeskuses on võimalik mängida golfi 18-rajalisel golfiväljakul või harjutada golfilööki erinevatel harjutusväljakutel.",
      contactUs: {

        ["Telefon", "tel:3725247700"]:Icon(Icons.phone_in_talk),
        ["E-post", "mailto:info@raegolf.ee"]:Icon(Icons.email),
        ["Veebileht", "https://raegolf.ee/"]: FaIcon(FontAwesomeIcons.globe),
        ["Instagram", "${instagramLink}raegolf"]:FaIcon(FontAwesomeIcons.instagram),
        ["Facebook", "${facebookLink}raegolf/"]:FaIcon(FontAwesomeIcons.facebook),
      },
    ),
    GolfCourse(
      location: [58.389967, 24.372171],
      name: "White Beach Golf",
      par: 72,
      distance: [4939, 5240, 5604, 6003, 6280],
      tees: ["Punased tiid", "Sinised tiid", "Kollased tiid", "Valged tiid", "Rohelised tiid"],
      teeColors: [Colors.red, Colors.blue, Colors.yellow, Colors.white, Colors.green],
      holes: {
        1:[5, [391, 405, 426, 451, 466]],
        2:[4, [282, 302, 322, 340, 360]],
        3:[4, [270, 281, 296, 310, 326]],
        4:[4, [283, 297, 332, 361, 371]],
        5:[3, [100, 118, 138, 158, 180]],
        6:[4, [304, 320, 340, 360, 380]],
        7:[5, [450, 470, 490, 506, 526]],
        8:[3, [120, 140, 160, 180, 190]],
        9:[4, [325, 340, 360, 395, 410]],

        10:[4, [295, 310, 330, 350, 370]],
        11:[5, [380, 400, 420, 440, 440]],
        12:[4, [240, 260, 280, 300, 320]],
        13:[3, [95, 104, 112, 122, 130]],
        14:[5, [389, 428, 468, 500, 516]],
        15:[4, [270, 290, 300, 315, 330]],
        16:[3, [120, 140, 160, 180, 200]],
        17:[4, [290, 290, 310, 330, 340]],
        18:[4, [335, 345, 360, 405, 425]],
      },
      image: "https://playgolfinestonia.com/wp-content/uploads/2018/11/pgie_wbg_slider-4.jpg",
      weather: "Valgeranna",
      description: "Pärnu lahe ilusaima ranna Valgeranna vahetus läheduses asub Pärnu maakonna esimene 18 rajaline golfiväljak White Beach Golf, mille on projekteerinud Kosti Kuronen. Selle links-tüüpi väljaku ehitust alustati sügisel 2002. Täismõõtmeline golfiväljak avati 1. juulil 2005. \nLisaks White Beach Golfi väljaku ääres looklevale Audru jõele võib sealt leida ka hulgaliselt tehisjärvesid ja tehiskuplid, mis toovad mängu põnevust ja pakuvad mängijaile silmailu.",
      contactUs: {
        ["Telefon", "tel:3724429930"]:Icon(Icons.phone_in_talk),
        ["E-post", "mailto:caddiemaster@wbg.ee"]:Icon(Icons.email),
        ["Veebileht", "https://wbg.ee/"]: FaIcon(FontAwesomeIcons.globe),
        ["Instagram", "${instagramLink}whitebeachgolf"]:FaIcon(FontAwesomeIcons.instagram),
        ["Facebook", "${facebookLink}whitebeachgolf"]:FaIcon(FontAwesomeIcons.facebook),
      },
    ),
    GolfCourse(
      location: [59.466925, 25.138494],
      name: "Estonian Golf & Country Club (Sea)",
      par: 72,
      distance: [5098, 5318,5692, 6202,6504],
      tees: ["Ladies tiid", "Senior tiid", "Club tiid", "Back tiid", "Championship tiid"],
      teeColors: [Colors.red, Colors.blue, Colors.yellow, Colors.white, Colors.black],
      holes: {
        1:[5, [414, 416,456, 500,530]],
        2:[4, [266, 294,298, 346,350]],
        3:[4, [282, 284,310, 348,352]],
        4:[4, [330, 334,380, 426,444]],
        5:[3, [110, 136,140, 154,158]],
        6:[5, [428, 462,466, 488,520]],
        7:[4, [342, 342,346, 370,406]],
        8:[3, [136, 162,166, 188,192]],
        9:[4, [276, 280,316, 342,346]],

        10:[3, [106, 124,140, 144,156]],
        11:[4, [330, 334,354, 398,402]],
        12:[4, [278, 302,306, 336,340]],
        13:[4, [286, 290,324, 328,380]],
        14:[4, [286, 290,322, 356,360]],
        15:[5, [416, 420,456, 490,524]],
        16:[4, [276, 304,308, 332,338]],
        17:[3, [122, 126,156, 176,180]],
        18:[5, [414, 418,448, 480,526]],

      },

      //Originally, img.techpowerup.org/200726/egcc-sea-1.png
      maps: [
        "${courseLink}egcc-sea-1.png",
        "${courseLink}egcc-sea-2.png",
        "${courseLink}egcc-sea-3.png",
        "${courseLink}egcc-sea-4.png",
        "${courseLink}egcc-sea-5.png",
        "${courseLink}egcc-sea-6.png",
        "${courseLink}egcc-sea-7.png",
        "${courseLink}egcc-sea-8.png",
        "${courseLink}egcc-sea-9.png",
        "${courseLink}egcc-sea-10.png",
        "${courseLink}egcc-sea-11.png",
        "${courseLink}egcc-sea-12.png",
        "${courseLink}egcc-sea-13.png",
        "${courseLink}egcc-sea-14.png",
        "${courseLink}egcc-sea-15.png",
        "${courseLink}egcc-sea-16.png",
        "${courseLink}egcc-sea-17.png",
        "${courseLink}egcc-sea-18.png",
      ],
      image: "https://egcc.ee/images/front_image.jpg",
      weather: "Jõelähtme",
      description: "Sea Course on tõeline championship-väljak. Põlismetsa sisse rajatud golfirajad ulatuvad mereni ja Jägala jõeni. Kõrguste vahe kuni 40 meetrit, tammealleed, vanad kivirahnud ja looduslikud tiigid on võimaldanud rajada sellise golfipärli, mida naljalt maailmas ei leia.",
      contactUs: {
        ["Telefon", "tel:3726025290"]:Icon(Icons.phone_in_talk),
        ["E-post", "mailto:welcome@egcc.ee"]:Icon(Icons.email),
        ["Veebileht", "https://egcc.ee/"]: FaIcon(FontAwesomeIcons.globe),
        ["Instagram", "${instagramLink}estoniangolf/"]:FaIcon(FontAwesomeIcons.instagram),
        ["Facebook", "${facebookLink}EstonianGolf"]:FaIcon(FontAwesomeIcons.facebook),
      },
    ),
    GolfCourse(
      location: [58.048784, 26.402907],
      name: "Otepää Golfiklubi",
      par: 73,
      distance: [5085, 5318,5651, 6202],
      tees: ["Punased tiid", "Sinised tiid", "Kollased tiid", "Valged tiid"],
      teeColors: [Colors.red, Colors.blue, Colors.yellow, Colors.white],
      holes: {
        1:[5, [435, 435,479, 490]],
        2:[4, [269, 269,316, 328]],
        3:[4, [218, 254,254, 269]],
        4:[4, [115, 123,123, 132]],
        5:[3, [288, 288,309, 326]],
        6:[5, [124, 157,157, 168]],
        7:[4, [197, 197,229, 239]],
        8:[3, [325, 325,360, 365]],
        9:[4, [380, 380,428, 464]],

        10:[3, [535, 602,602, 677]],
        11:[4, [290, 298,298, 349]],
        12:[4, [280, 280,290, 300]],
        13:[4, [98, 124,124, 170]],
        14:[4, [448, 448,505, 548]],
        15:[5, [135,135,165, 169]],
        16:[4, [118, 118,127, 135]],
        17:[3, [485, 465,510, 554]],
        18:[5, [345, 345,375, 390]],

      },
      image: "https://static2.visitestonia.com/images/3424494/20180923_Otepaa_golf_course_JM_004+copy.jpg",
      weather: "Mäha",
      description: "Otepää Golfiväljak on täismõõtmeline PAR73 golfirada. Ühtlasi on see Eesti üks parimaid ja kvaliteetsemaid golfiradu. Meil saab proovida ka Põhjamaades haruharva esinevat PAR6 rada (10.rada), mis on golfimängijate jaoks eksootiline.",
      contactUs: {
        ["Telefon", "tel:37256200115"]:Icon(Icons.phone_in_talk),
        ["Veebileht", "https://otepaagolf.ee/"]: FaIcon(FontAwesomeIcons.globe),
        ["Instagram", "${instagramLink}otepaagolf/"]:FaIcon(FontAwesomeIcons.instagram),
        ["Facebook", "${facebookLink}OtepaaGolfCenter"]:FaIcon(FontAwesomeIcons.facebook),
      },
    ),
    GolfCourse(
      location: [58.252710, 22.461901],
      name: "Saaremaa Golf & Country Club",
      par: 72,
      distance: [5037, 5536, 5800, 6315],
      tees: ["Punased tiid", "Sinised tiid", "Kollased tiid", "Valged tiid"],
      teeColors: [Colors.red, Colors.blue, Colors.yellow, Colors.white],
      holes: {
        1:[5,[417, 422, 460, 495]],
        2:[4, [304, 309, 337, 366]],
        3:[4, [287, 318, 325, 346]],
        4:[5, [387, 456, 461, 522]],
        5:[3, [93, 110, 115, 120]],
        6:[4, [292, 331, 335, 354]],
        7:[3, [159, 163, 199, 223]],
        8:[4, [308, 336, 359, 398]],
        9:[4, [279, 309, 315, 342]],

        10:[3,[83, 98, 101, 119]],
        11:[4, [331, 356, 381, 419]],
        12:[5, [390, 474, 479, 494]],
        13:[4, [279, 297, 304, 325]],
        14:[3, [121, 127, 152, 160]],
        15:[4, [268, 300, 330, 360]],
        16:[5, [397, 430, 436, 502]],
        17:[4, [321, 353, 358, 388]],
        18:[4, [321, 347, 353, 382]],
      },
      image: "https://www.saaregolf.ee/wp-content/uploads/8.jpg",
      weather: "Kuressaare",
      description: "Saaremaa Golf & Country Club koos Saare Golfiga on 18 rajaga championship-tüüpi golfikeskus, mis paikneb vaid jalutuskäigu kaugusel unikaalsest Kuressaare Linnusest, kesklinnast, hotellidest ja spaadest. Väljaku teeb eriliseks ümbritsev maastik, mis meenutab väljakul viibides ideaalse kompositsiooniga maali.",
      contactUs: {
        ["Telefon", "tel:3724533502"]:Icon(Icons.phone_in_talk),
        ["Veebileht", "https://saaregolf.ee/"]: FaIcon(FontAwesomeIcons.globe),
        ["Instagram", "${instagramLink}saaregolf/"]:FaIcon(FontAwesomeIcons.instagram),
        ["Facebook", "${facebookLink}saaregolf"]:FaIcon(FontAwesomeIcons.facebook),
      },
    ),
    GolfCourse(
      location: [57.725325, 26.915232],
      name: "Rõuge Golf",
      tees: ["Tiid"],
      teeColors: [Colors.grey],
      distance: [1652],
      par: 33,

      holes: {
        1:[3, [155]],
        2:[4, [216]],
        3:[3, [98]],
        4:[5, [310]],
        5:[5, [325]],
        6:[4, [208]],
        7:[3, [110]],
        8:[3, [80]],
        9:[3, [150]],
      },
      image:"https://img.techpowerup.org/200820/img-20200820-131049.jpg",
      description: "Rõuge golfisõprade loodud väljak golfimängu harrastamiseks.",
      weather: "Rõuge",
      contactUs: {
        ["Telefon", "tel:55603989"]: Icon(Icons.phone_in_talk),
        ["Facebook", "https://facebook.com/rougegolf/?tsid=0.4352174572472335&source=result"]: Icon(Icons.phone_in_talk),
      },
    ),



  ];


}