import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:loja_virtual_gerencial/validators/login_validators.dart';
import 'package:rxdart/rxdart.dart';

enum LoginState { IDLE, LOADING, SUCCESS, FAIL }

class LoginBloc extends BlocBase with LoginValidators {
  final _emailController = BehaviorSubject<String>();
  final _senhaController = BehaviorSubject<String>();
  final _stateController = BehaviorSubject<LoginState>();

  Stream<String> get outEmail =>
      _emailController.stream.transform(validateEmail);
  Stream<String> get outSenha =>
      _senhaController.stream.transform(validateSenha);

  Stream<String> get outState => _senhaController.stream;

  Stream<bool> get outSubmitValid =>
      Observable.combineLatest2(outEmail, outSenha, (a, b) => true);

  Function(String) get getChangeEmail => _emailController.sink.add;
  Function(String) get getChangeSenha => _senhaController.sink.add;

  LoginBloc() {
    FirebaseAuth.instance.onAuthStateChanged.listen((user) {
      if (user != null) {
        print("Logou!");
        FirebaseAuth.instance.signOut();
      } else {
        _stateController.add(LoginState.IDLE);
      }
    });
  }

  void submit() {
    final email = _emailController.value;
    final senha = _senhaController.value;

    _stateController.add(LoginState.LOADING);

    FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: senha)
        .catchError((e) {
      _stateController.add(LoginState.FAIL);
    });
  }

  @override
  void dispose() {
    _emailController.close();
    _senhaController.close();
    _stateController.close();
  }
}
