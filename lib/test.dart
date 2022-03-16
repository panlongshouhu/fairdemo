

void main(){
  dynamic an = Function.apply(() => Animal,null);

  print(an.toString());
}
class Animal {
int a = 232;
}