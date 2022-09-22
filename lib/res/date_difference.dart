import 'package:message_app/viewModel/auth_util.dart';

class MyDateFormat {
  static String getDateDifference(DateTime date) {
    final cLDate = date;
    final cFDate = DateTime.now();
    if(cLDate.year != cFDate.year){
      return "${cFDate.year - cLDate.year} years ago";
    }else{
      final difference = cFDate.difference(cLDate).inDays;
      if (difference == 0) {
        var hourDif = cFDate.difference(cLDate).inHours;
        var minDif = cFDate.difference(cLDate).inMinutes;
        if (minDif <= 59) {
          print("Min $minDif");
          if (minDif < 1) {
            var secDif = cFDate.difference(cLDate).inSeconds;
            print("Sec $secDif");
            return "$secDif sec ago";
          } else {
            return "$minDif min ago";
          }
        } else {
          return "$hourDif hrs ago";
        }
      } else if (difference < 7) {
        return "${cFDate.difference(cLDate).inDays} days ago";
      } else if (difference <= 30) {
        if (difference < 14) {
          return "1 weak ago";
        } else if (difference < 21) {
          return "2 weak ago";
        } else if (difference < 28) {
          return "3 weak ago";
        } else {
          return "4 weak ago";
        }
      } else if (difference < 365) {
        return "${cFDate.month - cLDate.month} months ago";
      } else {
        if (cLDate.year == cFDate.year) {
          return "1 years ago";
        } else {
          return "${cLDate.year - cFDate.year} years ago";
        }
      }
    }
  }

  static bool getTypingStatus(String date, String uid){
    final cLDate = DateTime.fromMillisecondsSinceEpoch(int.parse(date));
    final cFDate = DateTime.now();
    var secDiff = cFDate.difference(cLDate).inSeconds;
    if(uid == AuthUtil.firebaseAuth.currentUser!.uid){
      if(secDiff <= 1 && cLDate.second <= cFDate.second){
        return true;
      }else{
        return false;
      }
    }else{
      return false;
    }
  }

  static String getOnlineTimeStatus(String date) {
    final cLDate = DateTime.fromMillisecondsSinceEpoch(int.parse(date));
    final cFDate = DateTime.now();
    if(cLDate.second > cFDate.second){
      return "Offline";
    }
    if(cLDate.year != cFDate.year){
      return "${cFDate.year - cLDate.year} years ago";
    }else{
      final difference = cFDate.difference(cLDate).inDays;
      if (difference == 0) {
        var hourDif = cFDate.difference(cLDate).inHours;
        var minDif = cFDate.difference(cLDate).inMinutes;
        if (minDif <= 59) {
          print("Min $minDif");
          if (minDif < 1 && minDif >= 0) {
            // var secDif = cFDate.difference(cLDate).inSeconds;
            // print("Sec $secDif");
            // return "$secDif seconds ago";
            return "Online";
          } else {
            return "$minDif minutes ago";
          }
        } else {
          return "$hourDif hours ago";
        }
      } else if (difference < 7) {
        return "${cFDate.difference(cLDate).inDays} days ago";
      } else if (difference <= 30) {
        if (difference < 14) {
          return "1 weak ago";
        } else if (difference < 21) {
          return "2 weak ago";
        } else if (difference < 28) {
          return "3 weak ago";
        } else {
          return "4 weak ago";
        }
      } else if (difference < 365) {
        print("Disfferences $difference");
        return "${cFDate.month - cLDate.month} months ago";
      } else {
        if (cLDate.year == cFDate.year) {
          return "1 years ago";
        } else {
          return "${cLDate.year - cFDate.year} years ago";
        }
      }
    }
  }
}
