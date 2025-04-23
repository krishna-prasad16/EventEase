import 'package:decorators/main.dart';
import 'package:flutter/material.dart';


class CatChangepassword extends StatefulWidget {
  const CatChangepassword({super.key});

  @override
  State<CatChangepassword> createState() => _CatChangepasswordpwdState();
}

class _CatChangepasswordpwdState extends State<CatChangepassword> {
  final TextEditingController currentpwdController = TextEditingController();
  final TextEditingController newpwdController = TextEditingController();
  final TextEditingController confirmpwdController = TextEditingController();

  bool showCurrent = false;
  bool showNew = false;
  bool showConfirm = false;

  Future<void> updatepwd() async {
    final String currentPwd = currentpwdController.text.trim();
    final String newPwd = newpwdController.text.trim();
    final String confirmPwd = confirmpwdController.text.trim();

    if (currentPwd.isEmpty || newPwd.isEmpty || confirmPwd.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }
    if (newPwd != confirmPwd) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('New password and confirm password do not match')),
      );
      return;
    }
    try {
      String? userData = supabase.auth.currentUser!.id;
      await supabase.from('tbl_catering').update({
        'cat_password': newPwd,
      }).eq('id', userData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Password Updated',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );
      await fetchpass();
      newpwdController.clear();
      confirmpwdController.clear();
    } catch (e) {
      print('ERROR UPDATING PASSWORD:$e');
    }
  }

  Future<void> fetchpass() async {
    try {
      String? userData = supabase.auth.currentUser!.id;
      if (userData != null) {
        final response = await supabase
            .from('tbl_catering')
            .select()
            .eq('id', userData)
            .single();
        setState(() {
          currentpwdController.text = response['cat_password'];
        });
      } else {
        print('Error');
      }
    } catch (e) {
      print('ERROR FETCHING PASSWORD:$e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchpass();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8f9fa),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Change Password', style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
      ),
      body: Center(
        child: Card(
          elevation: 6,
          margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Text(
                    'Update your password',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFbc6c25)),
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: currentpwdController,
                    obscureText: !showCurrent,
                    decoration: InputDecoration(
                      labelText: 'Current Password',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(showCurrent ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => showCurrent = !showCurrent),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: newpwdController,
                    obscureText: !showNew,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(showNew ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => showNew = !showNew),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: confirmpwdController,
                    obscureText: !showConfirm,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(showConfirm ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => showConfirm = !showConfirm),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: updatepwd,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFbc6c25),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Update',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
