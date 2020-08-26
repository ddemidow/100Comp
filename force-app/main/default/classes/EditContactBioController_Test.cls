@isTest
private  class EditContactBioController_Test {
	static testMethod void testRedirect() {
		FFA_TestUtility testUtil = new FFA_TestUtility();
		User testUser = testUtil.newUserSysAdmin(true);

		Account testAccount = testUtil.newAccount(true);

		Contact testContact = testUtil.newResource(true, testAccount.Id, testUser.Id);

		System.runAs(testUser){
			EditContactBioController controller = new EditContactBioController();
			PageReference ref = controller.redirectToBio();
			System.assert(ref.getUrl().contains((String)testContact.Id));
		}
	}

	static testMethod void testFailedRedirect() {
		FFA_TestUtility testUtil = new FFA_TestUtility();
		User testUser1 = testUtil.newUserSysAdmin(true);
		User testUser2 = testUtil.newUserSysAdmin(true);

		Account testAccount = testUtil.newAccount(true);

		Contact testContact = testUtil.newResource(true, testAccount.Id, testUser1.Id);

		System.runAs(testUser2){
			EditContactBioController controller = new EditContactBioController();
			PageReference ref = controller.redirectToBio();
			System.assertEquals(null, ref, 'Page Reference should be null');
		}
	}
}