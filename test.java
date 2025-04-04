// value가 3인지 검사 후 3의 배수면 ret애 3저장, else if 써서 4면 ret=4 저장

public class IfExam {   
    public int IfTest(int value){
        int ret=0;
        if(value % 3 ==0 ){
            ret = 3;
        } 
        else if
         (value % 4 == 0){
            ret = 4;
            return ret;
        }
        public static void main(String[]args) {
            IfExam exam = new IfExam();
            System.out.println(exam.IfExam(6)); //3의 배수
            System.out.println(exam.IfExam(8)); // 4의 배수
        }
    }

}
