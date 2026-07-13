import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: const Text(
          '''Privacy Policy for Twouple

Last Updated: [Current Date]

1. Introduction
Welcome to Twouple ("we", "our", or "us"). We are committed to protecting your personal information and your right to privacy. If you have any questions or concerns about this privacy notice or our practices with regard to your personal information, please contact us.

When you use our mobile application (the "App") and more generally, use any of our services (the "Services"), we appreciate that you are trusting us with your personal information. We take your privacy very seriously. In this privacy notice, we seek to explain to you in the clearest way possible what information we collect, how we use it, and what rights you have in relation to it.

2. Information We Collect
We collect personal information that you voluntarily provide to us when you register on the App, express an interest in obtaining information about us or our products and Services, when you participate in activities on the App, or otherwise when you contact us.

The personal information that we collect depends on the context of your interactions with us and the App, the choices you make, and the products and features you use. The personal information we collect may include the following:
* Personal Info Provided by You. We collect names; email addresses; passwords; and other similar information.
* Couple Data. We may collect information related to your relationship, interactions with your partner within the app, shared calendars, memories, and chat logs, to provide the core functionality of the App.

3. How We Use Your Information
We use personal information collected via our App for a variety of business purposes described below. We process your personal information for these purposes in reliance on our legitimate business interests, in order to enter into or perform a contract with you, with your consent, and/or for compliance with our legal obligations. We use the information we collect or receive:
* To facilitate account creation and logon process.
* To provide and manage Services to you.
* To respond to user inquiries/offer support to users.
* To send administrative information to you.
* To protect our Services.

4. Will Your Information Be Shared With Anyone?
We only share information with your consent, to comply with laws, to provide you with services, to protect your rights, or to fulfill business obligations.

* Your Partner: By design, much of the information you input into Twouple is shared with the partner you have linked your account to.
* Vendors, Consultants, and Other Third-Party Service Providers. We may share your data with third-party vendors, service providers, contractors, or agents who perform services for us or on our behalf and require access to such information to do that work.

5. How Long Do We Keep Your Information?
We will only keep your personal information for as long as it is necessary for the purposes set out in this privacy notice, unless a longer retention period is required or permitted by law (such as tax, accounting, or other legal requirements).

6. How Do We Keep Your Information Safe?
We have implemented appropriate technical and organizational security measures designed to protect the security of any personal information we process. However, despite our safeguards and efforts to secure your information, no electronic transmission over the Internet or information storage technology can be guaranteed to be 100% secure.

7. What Are Your Privacy Rights?
Depending on your location, you may have the right to request access to the personal information we collect from you, change that information, or delete it in some circumstances. To request to review, update, or delete your personal information, please submit a request form by contacting us.

8. Updates to This Notice
We may update this privacy notice from time to time. The updated version will be indicated by an updated "Revised" date and the updated version will be effective as soon as it is accessible. If we make material changes to this privacy notice, we may notify you either by prominently posting a notice of such changes or by directly sending you a notification. We encourage you to review this privacy notice frequently to be informed of how we are protecting your information.

9. Contact Us
If you have questions or comments about this notice, you may email us at support@twouple.com.''',
          style: TextStyle(fontSize: 16.0, height: 1.5),
        ),
      ),
    );
  }
}
