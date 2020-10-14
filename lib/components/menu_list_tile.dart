import 'package:flash_chat/components/birthdays.dart';
import 'package:flash_chat/components/gratitude.dart';
import 'package:flash_chat/components/reminders.dart';
import 'package:flutter/material.dart';

class MenuListTileWidget extends StatelessWidget {
  const MenuListTileWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          leading: Icon(Icons.group_add),
          title: Text('New Group'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewGroup(),
                ));
          },
        ),
        ListTile(
          leading: Icon(Icons.record_voice_over),
          title: Text('New Channel'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewChannel(),
                ));
          },
        ),
        ListTile(
          leading: Icon(Icons.person),
          title: Text('Contacts'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Contacts(),
                ));
          },
        ),
        Divider(
          color: Colors.grey,
        ),
        ListTile(
          leading: Icon(Icons.settings),
          title: Text('Setting'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        AboutListTile(
          icon: Icon(Icons.info_outline),
          applicationName: 'Flash Chat',
          applicationVersion: '1.0.0',
          applicationLegalese:
              'Flash Chat is very fast chat app developed by Miruts hadush, contact developer @ miruts.hadush@aait.edu.et',
        )
      ],
    );
  }
}
