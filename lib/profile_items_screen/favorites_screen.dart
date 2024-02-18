import 'package:flutter/material.dart';

class FavoritesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites Screen'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: <Widget>[
          FavoriteItem(title: 'Item Favorit 1', subtitle: 'Deskripsi Item 1'),
          FavoriteItem(title: 'Item Favorit 2', subtitle: 'Deskripsi Item 2'),
          FavoriteItem(title: 'Item Favorit 3', subtitle: 'Deskripsi Item 3'),
        ],
      ),
    );
  }
}

class FavoriteItem extends StatelessWidget {
  final String title;
  final String subtitle;

  FavoriteItem({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5.0,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: IconButton(
          icon: Icon(Icons.favorite, color: Colors.red),
          onPressed: () {},
        ),
        onTap: () {},
      ),
    );
  }
}
