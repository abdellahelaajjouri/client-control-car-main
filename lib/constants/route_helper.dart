import 'dart:convert';

import 'package:client_control_car/models/last_messages_model.dart';
import 'package:client_control_car/pages/auth/forgot_pass_screen.dart';
import 'package:client_control_car/pages/auth/login_screen.dart';
import 'package:client_control_car/pages/auth/otp_phone_screen.dart';
import 'package:client_control_car/pages/auth/reg_by_phone_screen.dart';
import 'package:client_control_car/pages/auth/reinitial_password_screen.dart';
import 'package:client_control_car/pages/book_rdv/dart_time_screen.dart';
import 'package:client_control_car/pages/book_rdv/facturation_screen.dart';
import 'package:client_control_car/pages/book_rdv/forfait_control_screen.dart';
import 'package:client_control_car/pages/book_rdv/resume_commande_screen.dart';
import 'package:client_control_car/pages/carte_grise/add_carte_grise.dart';
import 'package:client_control_car/pages/carte_grise/carte_grise_home.dart';
import 'package:client_control_car/pages/chat/list_chat_from_screen.dart';
import 'package:client_control_car/pages/chat/list_last_chat_screen.dart';
import 'package:client_control_car/pages/contact_assistance/contact_assistance_screen.dart';
import 'package:client_control_car/pages/contact_assistance/detail_ticket_screen.dart';
import 'package:client_control_car/pages/demo/demo_screen.dart';
import 'package:client_control_car/pages/historys/consulter_rapport_page.dart';
import 'package:client_control_car/pages/historys/image_show_screen.dart';
import 'package:client_control_car/pages/historys/mes_commande_detail_page.dart';
import 'package:client_control_car/pages/historys/mes_commande_page.dart';
import 'package:client_control_car/pages/home/home_map_screen.dart';
import 'package:client_control_car/pages/info_vehicule/info_vehicule_screen.dart';
import 'package:client_control_car/pages/notification/notification_screen.dart';
import 'package:client_control_car/pages/payment/add_card_payment_screen.dart';
import 'package:client_control_car/pages/payment/payment_method_screen.dart';
import 'package:client_control_car/pages/payment/stripe_cancel_screen.dart';
import 'package:client_control_car/pages/payment/stripe_success_screen.dart';
import 'package:client_control_car/pages/profil/profil_screen.dart';
import 'package:client_control_car/pages/splash/splash_screen.dart';
import 'package:get/get.dart';

class RouteHelper {
  // const
  static const String splash = '/splash';
  static const String demo = '/demo';
  static const String loginPage = '/login-page';
  static const String regByPhonePage = '/inscrire-byphone-page';
  static const String otpPhonePage = '/otp-phone-page';
  static const String inscriptionPage = '/inscription-page';
  static const String homeMapPage = '/home-map-page';
  static const String bookRdvDateTimePage = '/book-rdv-date-page';
  static const String bookForfaitControlPage = '/book-forfait-control-page';
  static const String bookFacturationPage = '/book-facturation-page';
  static const String bookResumCommandPage = '/book-resume-command-page';
  static const String paymentMethodPage = '/payment-method-page';
  static const String addCardpaymentPage = '/add-card-payment-page';
  static const String profilPage = '/profil-page';
  static const String notificationPage = '/notification-page';
  static const String infoVehiculePage = '/info-vehicule-page';
  static const String carteGriseHomePage = '/carte-grise-home-page';
  static const String addCarteGrisePage = '/add-carte-grise-page';
  static const String mesCommandesPage = '/mes-commandes-page';
  static const String mesCommandesDetailPage = '/mes-commandes-detail-page';
  static const String listLastChatPage = '/list-last-chat-page';
  static const String listChatFromPage = '/list-chat-from-page';
  static const String contactAssistancePage = '/contact-assistance-page';
  static const String consultRapportPage = '/consult-rapport-page';
  static const String showImagePage = '/show-image-page';
  static const String forgotPassPage = '/forgot-pass-page';
  static const String reinitialPassPage = '/reinitial-pass-page';
  static const String detailTicketPage = '/detail-ticket-page';

  static const String stripeCancelPage = '/payment-cancel-page';
  static const String stripeSuccessPage = '/payment-success-page';
  static const String stripeWebViewPage = '/payment-web-view-page';
  // function
  static String getSplashRoute() => splash;
  static String getForgotPassRoute() => forgotPassPage;
  static String getDemoRoute() => demo;
  static String getLoginRoute() => loginPage;
  static String getRegByPhoneRoute() => regByPhonePage;
  static String getOtpPhoneRoute(
          {required String otpCode, required String phone}) =>
      "$otpPhonePage?otpCode=$otpCode&phone=$phone";
  static String getInsciprionRoute(
          {required String otpCode, required String phone}) =>
      "$inscriptionPage?otpCode=$otpCode&phone=$phone";
  static String getHomeMapRoute() => homeMapPage;
  static String getBookRdvDateTimeRoute() => bookRdvDateTimePage;
  static String getForfaitControlPageRoute() => bookForfaitControlPage;
  static String getFacturationPageRoute() => bookFacturationPage;
  static String getResumCommandPageRoute({required String countrolId}) =>
      "$bookResumCommandPage?countrolId=$countrolId";
  static String getPaymentMethodRoute(
      {required String controlId,
      required String total,
      required String hasCoupon,
      required String discount}) {
    return "$paymentMethodPage?controlId=$controlId&total=$total&discount=$discount&hasCoupon=$hasCoupon";
  }

  static String getAddCardPaymentRoute() => addCardpaymentPage;
  static String getProfilRoute() => profilPage;
  static String getNotificationRoute() => notificationPage;
  static String getInfoVehiculeRoute() => infoVehiculePage;
  static String getCarteGriseHomeRoute() => carteGriseHomePage;
  static String getAddCarteGriseRoute() => addCarteGrisePage;
  static String getMesCommandeRoute() => mesCommandesPage;
  static String getMesCommandeDetailRoute({required String countrolId}) =>
      "$mesCommandesDetailPage?countrolId=$countrolId";
  static String getListLastChatRoute() => listLastChatPage;
  static String getContactAssistanceRoute() => contactAssistancePage;
  static String getListChatFromRoute({required UserChat userChat}) {
    String user = base64Url.encode(utf8.encode(jsonEncode(userChat.toJson())));
    return "$listChatFromPage?userChat=$user";
  }

  static String getShowImageRoute({required String url}) =>
      "$showImagePage?url=$url";
  static String getConsultRapportRoute({required String idcontrol}) =>
      "$consultRapportPage?idcontrol=$idcontrol";
  static String getReinitialPasswordRoute({required String email}) =>
      "$reinitialPassPage?email=$email";
  static String getDetailTicketRoute({required String idTicket}) =>
      "$detailTicketPage?idTicket=$idTicket";

  static String getStripeCancelRoute(
          {required String controlId,
          required String total,
          required String hasCoupon,
          required String discount}) =>
      "$stripeCancelPage/?controlId=$controlId&total=$total&hasCoupon=$hasCoupon&discount=$discount";
  static String getStripeSuccessRoute() => "$stripeSuccessPage/";
  static String getStripeWebViewRoute({
    required String controlId,
    required String total,
    required String hasCoupon,
    required String discount,
    required String session,
  }) =>
      "$stripeWebViewPage?controlId=$controlId&total=$total&hasCoupon=$hasCoupon&discount=$discount&session=$session";

  // list Routes
  static List<GetPage> routes = [
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: demo,
      page: () => const DemoScreen(),
    ),
    GetPage(
      name: loginPage,
      page: () => const LoginScreen(),
    ),
    GetPage(
      name: homeMapPage,
      page: () => const HomeMapScreen(),
    ),
    GetPage(
      name: bookRdvDateTimePage,
      page: () => const DatTimeScreen(),
    ),
    GetPage(
      name: bookForfaitControlPage,
      page: () => const ForfaitControlScreen(),
    ),
    GetPage(
      name: bookFacturationPage,
      page: () => const FacturationScreen(),
    ),
    GetPage(
      name: bookResumCommandPage,
      page: () {
        return ResumeCommandeScreen(
          countrolId: Get.parameters["countrolId"]!,
        );
      },
    ),
    GetPage(
      name: paymentMethodPage,
      page: () => PaymentMethodScreen(
        controlId: Get.parameters["controlId"]!,
        total: Get.parameters["total"]!,
        hasCoupon: Get.parameters["hasCoupon"]!,
        discount: Get.parameters["discount"]!,
      ),
    ),
    GetPage(
      name: addCardpaymentPage,
      page: () => const AddCardPaymentScreen(),
    ),
    GetPage(
      name: regByPhonePage,
      page: () => const RegByPhoneScreen(),
    ),
    GetPage(
      name: otpPhonePage,
      page: () {
        return OtpPhoneScreen(
          otpCode: Get.parameters["otpCode"]!,
          phone: Get.parameters["phone"]!,
        );
      },
    ),
    GetPage(
      name: profilPage,
      page: () => const ProfilScreen(),
    ),
    GetPage(
      name: notificationPage,
      page: () => const NotificationScreen(),
    ),
    GetPage(
      name: infoVehiculePage,
      page: () => const InfoVehiculeScreen(),
    ),
    GetPage(
      name: carteGriseHomePage,
      page: () => const CarteGriseHomePage(),
    ),
    GetPage(
      name: addCarteGrisePage,
      page: () => const AddCarteGrise(),
    ),
    GetPage(
      name: mesCommandesPage,
      page: () => const MesCommandePage(),
    ),
    GetPage(
        name: mesCommandesDetailPage,
        page: () {
          return MesCommandeDetailPage(
            controlId: Get.parameters["countrolId"]!,
          );
        }),
    GetPage(
      name: listLastChatPage,
      page: () => const ListLastChatScreen(),
    ),
    GetPage(
      name: listChatFromPage,
      page: () => ListChatFromScreen(
        userChat: UserChat.fromJson(
          jsonDecode(
            utf8.decode(
              base64Url
                  .decode(Get.parameters["userChat"]!.replaceAll(" ", "+")),
            ),
          ),
        ),
      ),
    ),
    GetPage(
      name: contactAssistancePage,
      page: () => const ContactAssistanceScreen(),
    ),
    GetPage(
      name: consultRapportPage,
      page: () => ConsultRapportScreen(
        idcontrol: Get.parameters["idcontrol"]!,
      ),
    ),
    GetPage(
      name: showImagePage,
      page: () => ImageShowScreen(
        url: Get.parameters["url"]!,
      ),
    ),
    GetPage(
      name: forgotPassPage,
      page: () => const ForgotPassScreen(),
    ),
    GetPage(
      name: reinitialPassPage,
      page: () => ReinitialPasswordScreen(
        email: Get.parameters["email"]!,
      ),
    ),
    GetPage(
      name: detailTicketPage,
      page: () => DetailTicketScreen(
        idTicket: Get.parameters["idTicket"]!,
      ),
    ),
    GetPage(
      name: stripeCancelPage,
      page: () => StripeCancelScreen(
        controlId: Get.parameters["controlId"]!,
        total: Get.parameters["total"]!,
        hasCoupon: Get.parameters["hasCoupon"]!,
        discount: Get.parameters["discount"]!,
      ),
    ),
    GetPage(
      name: stripeSuccessPage,
      page: () => const StripeSuccessScreen(),
    ),
  ];
}
