import 'package:mongo_dart/mongo_dart.dart';

void main() async {
  print('Attempting to connect to mongodb://localhost:27017/pos_system_dev...');
  try {
    final db = await Db.create('mongodb://localhost:27017/pos_system_dev');
    await db.open();
    print('Connected successfully!');
    
    final collection = db.collection('units');
    final doc = {
      'unit_name': 'Test Kilogram',
      'short_name': 't-kg',
      'is_active': true,
      'created_at': DateTime.now(),
    };
    print('Inserting test document...');
    final result = await collection.insertOne(doc);
    print('Insert result: $result');
    
    print('Reading document back...');
    final found = await collection.findOne(where.eq('short_name', 't-kg'));
    print('Found document: $found');
    
    print('Cleaning up test document...');
    await collection.deleteOne(where.eq('short_name', 't-kg'));
    print('Cleanup done.');
    
    await db.close();
    print('Database connection closed.');
  } catch (e) {
    print('Error connecting or querying database: $e');
  }
}
