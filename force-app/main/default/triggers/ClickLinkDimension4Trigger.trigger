trigger ClickLinkDimension4Trigger on c2g__codaDimension4__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
 ffirule.IntegrationRuleEngine.triggerHandler();
  }