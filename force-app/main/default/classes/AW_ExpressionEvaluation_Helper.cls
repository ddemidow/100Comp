// 
// (c) 2012 Appirio, Inc.
//
//  AW_ExpressionEvaluation_Helper	                                                  
//
// This class is used to evaluate expressions for rule criteria
//
// 10 Oct 2012     Peter Babalis     Original
//  
//  
public class AW_ExpressionEvaluation_Helper{
    
    private Integer top=-1; 
    
    String[] stack = new List<String>();
    
    //returns the precedence of the symbol
    private Integer getPriority(String symbol){
        if(symbol=='*') return 4;
        
        if(symbol=='+') return 2;
        
        return 1;
    }
    
    private Boolean isOperator(String symbol){
            if(symbol == '*' || symbol == '+' || symbol=='(' || symbol==')' )
                return true;
            else
                return false;
    }
    
    private void push(String item){
        top++;
        stack.add(item);
    }
    
    private String pop(){
        String  ret= stack.remove(top);
        top--;
        return ret; 
    }
    
    public String[] convertInfixToPostfix(String infix){
         infix = infix.toLowerCase();
         infix = infix.replaceAll('and', '*');
         infix = infix.replaceAll('or', '+');
         
         Integer i,j=0;
         
         String symbol;
         String[] postfix = new List<String>();
         ++top;
         stack.add('#');
          
         Integer length = infix.length();
         for(i=0;i<length;i++){
             symbol = charAt(infix,i);
             if(symbol.trim()=='') continue;
             if(!isOperator(symbol)){
                postfix.add(symbol); 
                j++;  
             }else{
                if(symbol=='(')push(symbol);  
                else if(symbol==')') {
                    while(stack[top]!='(') 
                    { 
                        postfix.add(pop()); 
                        j++; 
                    }                    
                    pop(); //(
                }else{ 
                    if(getPriority(symbol)>getPriority(stack[top])) 
                        push(symbol); 
                    else{ 
                        while(getPriority(symbol)<=getPriority(stack[top])) 
                        { 
                            postfix.add(pop()); 
                            j++; 
                        } 
                        push(symbol); 
                    }//end of else. 
                }//end of else. 
             }//end else
         }//end for
         
         while(stack[top]!='#') 
         { 
            postfix.add(pop()); 
            j++; 
         } 
         
         system.debug(postfix);
         return postfix;     
    }
    
    private String charAt(String str, Integer index) {
            if(str == null){
                return null;
            }
            if(str.length() <= 0){
                return str; 
            }
            if(index < 0 || index >= str.length()){
                return null;    
            }
            return str.substring(index, index+1);
   }
   
   public Boolean evaluateExpression(String filterLogic,Map<Integer,Integer> result){
   		
   		for(Integer i:result.keySet())
   			filterLogic=filterLogic.replace(string.valueof(i),string.valueof(result.get(i)));
   		 		   		
   		return evaluatePostfixExpression(convertInfixToPostfix(filterLogic));
   }
   
   public Boolean evaluatePostfixExpression(List<String> postfix){
   		
   		Integer length = postfix.size();
   		String symbol;
   		  		   		
   		
   		top=-1; // reinitialize
   		stack.clear();
   		
   		for(Integer i=0;i<length;i++){
   			 symbol = postfix[i];
   			 
   			 if(!isOperator(symbol)){
   			 	push(symbol);
   			 }else{
   			 	//evaluate the result here and push the result back to the stack
   			 	Integer op1 = Integer.valueOf(pop());
   			 	Integer op2 = Integer.valueOf(pop());
   			 	Integer res=0;
   			 	
   			 	if(symbol=='*'){
   			 		res = op1*op2;
   			 	}else {
   			 		res = op1+op2;
   			 		res = res>1 ?1:res;
   			 		
   			 	}
   			 	
   			 	//now push the result back to stack  			 
   			 	push(string.valueOf(res));   			 	
   			 }  			 
   		}
   		
   		//finally 		
   		return Integer.valueof(pop()) >=1 ? true:false;   		
   }
    
}