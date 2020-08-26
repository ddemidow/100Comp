trigger PopulatePrimaryCampaign on Opportunity (before insert) {
    for(Opportunity opp : trigger.new)
    {
        Schema.DescribeSObjectResult oppDesc = Opportunity.sObjectType.getDescribe();
        Map<String,Schema.recordTypeInfo> mapRecordsType = oppDesc.getRecordTypeInfosByName();
        // S-265151 - By Hemlata - Added opp.Group2__c != 'The Miles Group'
        if(opp.Participant_Contact__c!= null && (mapRecordsType.get('Advisory Services').getRecordTypeId() == opp.recordTypeId || mapRecordsType.get('Training Services').getRecordTypeId() == opp.recordTypeId) && opp.Group2__c != 'The Miles Group')
        {
            List<CampaignMember> member = new List<CampaignMember>();
            member = [Select ContactId, CampaignId From CampaignMember where ContactId = :opp.Participant_Contact__c order by createdDate desc limit 1];
            if(member!= null && member.size()>0)
            {
                opp.CampaignId = member.get(0).CampaignId;
            }
        }
    }

}