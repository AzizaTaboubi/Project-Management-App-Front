import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:managementappfront/cards.dart';
import 'package:managementappfront/home.dart';
import 'package:managementappfront/workspaces.dart';

import 'login.dart';

class SettingsPage1 extends StatelessWidget {
  const SettingsPage1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 249, 249, 249),
      
           
       appBar: AppBar(backgroundColor: Colors.white70,
       title: Row(
        children: [
         
          Text(
            'Settings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
               letterSpacing: 1,
               color: Colors.black87
            ),
          ),
        ]
       ),
       ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: ListView(
            children: [
              _SingleSection(
                title: "Notifications",
                children: [
                  const _CustomListTile(
                      title: "Open System Settings",
                      icon: CupertinoIcons.device_phone_portrait),
                ],
              ),
              _SingleSection(
                title: "Theme",
                children: [
                  const _CustomListTile(
                      title: "Choose Theme",
                      icon: CupertinoIcons.color_filter_fill),

                ],
              ),
              const _SingleSection(
                title: "Accessibility",
                children: [
                  _CustomListTile(
                      title: "Color blind friendly", icon: CupertinoIcons.person_2),
                  _CustomListTile(
                      title: "Enable Animations", icon: Icons.animation),
                  _CustomListTile(
                      title: "Show labels names", icon: Icons.label),
                ],
              ),
                const _SingleSection(
                title: "Sync",
                children: [
                  _CustomListTile(
                      title: "Offline boards", icon: CupertinoIcons.bookmark),
                  _CustomListTile(
                      title: "Sync queue", icon: Icons.queue),
                ],
              ),
                const _SingleSection(
                title: "General",
                children: [
                  _CustomListTile(
                      title: "Profile and visibility", icon: Icons.person_2_rounded),
                  _CustomListTile(
                      title: "Create card defaults", icon: Icons.card_membership_rounded),
                  _CustomListTile(
                      title: "Help", icon: Icons.help),
                      
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomListTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget? trailing;
  const _CustomListTile(
      {Key? key, required this.title, required this.icon, this.trailing})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      leading: Icon(icon),
      trailing: trailing ?? const Icon(CupertinoIcons.forward, size: 18),
      onTap: () {},
    );
  }
}

class _SingleSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SingleSection({
    Key? key,
    required this.title,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title.toUpperCase(),
            style:
                Theme.of(context).textTheme.headline3?.copyWith(fontSize: 16),
          ),
        ),
        Container(
          width: double.infinity,
          color: Colors.white,
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}
