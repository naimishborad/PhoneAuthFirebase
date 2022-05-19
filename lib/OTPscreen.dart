import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:phoneauth2/home.dart';
import 'package:pinput/pinput.dart';

class OTPscreen extends StatefulWidget {
  final String Phone;

  const OTPscreen(this.Phone);
  
  

  @override
  State<OTPscreen> createState() => _OTPscreenState();
  
}
class _OTPscreenState extends State<OTPscreen> {
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _verifyPhone();
  }

  final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();
  late String _verificationCode;
  final TextEditingController _pinPutController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();
  final BoxDecoration pinPutDecoration = BoxDecoration(
    color: const Color.fromRGBO(43, 46, 66, 1),
    borderRadius: BorderRadius.circular(10.0),
    border: Border.all(
      color: const Color.fromRGBO(126, 203, 224, 1),
    ),
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldkey,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                child: Center(
                  child: Text('Verify +91${widget.Phone}',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.all(20),
                child: Pinput(
                  length: 6,
                  focusNode: _pinPutFocusNode,
                  controller:  _pinPutController,
                  pinAnimationType: PinAnimationType.fade,
                  onSubmitted: (pin)async{
                    try {
                      await FirebaseAuth.instance.signInWithCredential(
                        PhoneAuthProvider.credential(verificationId: _verificationCode, smsCode: pin)
                      ).then((value) async{
                        if(value.user != null){
                          Navigator.pushAndRemoveUntil(
                            context, MaterialPageRoute(builder: (context)=>Home()), (route) => false);
                        }
                      }
                      );
                    } catch (e) {
                      FocusScope.of(context).unfocus();
                      _scaffoldkey.currentState!.showSnackBar(SnackBar(content: Text('Invalid OTP')));
                    }
                  },
                )
              )
              
            ],
          ),
        ),
      ),
      
    );
  }
   _verifyPhone() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+91${widget.Phone}',
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance
              .signInWithCredential(credential)
              .then((value) async {
            if (value.user != null) {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => Home()),
                  (route) => false);
            }
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          print(e.message);
        },
        codeSent: (String verficationID, int? resendToken) {
          setState(() {
            _verificationCode = verficationID;
          });
        },
        codeAutoRetrievalTimeout: (String verificationID) {
          setState(() {
            _verificationCode = verificationID;
          });
        },
        timeout: Duration(seconds: 120));
  }

}
