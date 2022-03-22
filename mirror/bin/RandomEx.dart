import 'dart:math';

extension RandomEx on Random {
  static dynamic instance(String name,List<dynamic> positionalArguments){
    if(name == 'Random'){
      return Function.apply(()=>Random(), positionalArguments);
    }
    if(name == 'secure'){
      return Function.apply(()=>Random.secure(), positionalArguments);
    }
    return null;
  }

  static dynamic invoke(Random random,String name,List<dynamic> positionalArguments){
    if(name == 'toString'){
      return Function.apply(()=>random.toString(), positionalArguments);
    }
    return null;
  }
}