public class AW_ApexJob_ActionSample implements AW_RuleActionInterface{
        
      //  public Map<String,STring> runAction(Map<String,String> params){
       public Map<String,STring> runAction(Map<String,String> mapInputParm){
            //SObject sobj = (SObject)mapInputParm.get('objInstance');
            //do some action here say get :-
            Map<String,STring> returndata= new Map<String,STring>();
            returndata.put('desc','this is from apex job');
            return returndata;
        }
        public String getImplementedObjApiName(){
            return 'Account'; 
        }
}