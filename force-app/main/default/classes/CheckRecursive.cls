public class CheckRecursive {
   @TestVisible 
   private static boolean run = true;
   private static boolean runHandleMilestoneAfter = true;
 
   public static boolean runOnce() {
      if (run) {
          run = false;
          return true;
      } else {
          return run;
      }
  }
  public static boolean runOnceHandleMilestoneAfterTrigger() {
      if (runHandleMilestoneAfter) {
          runHandleMilestoneAfter = false;
          return true;
      } else {
          return runHandleMilestoneAfter;
      }
  }
}