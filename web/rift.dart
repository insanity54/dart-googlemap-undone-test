import 'dart:html';
import 'package:google_maps/google_maps.dart';
import 'package:undone/undone.dart';

// click on map to create marker
//   - add location name
//   - add add charge #


String genTitle() => (chargeNumber += 1).toString();

final mapOptions = new MapOptions()
..zoom = 15
..center = new LatLng(47.657, -117.449)
..mapTypeId = MapTypeId.ROADMAP;
final map = new GMap(querySelector("#map-canvas"), mapOptions);

final ButtonElement undoButton = querySelector('#undo');
final ButtonElement redoButton = querySelector('#redo');

var args = { 'event' : null, 'oldPos' : null }; // arguments for undoable actions

int chargeNumber = 0;  // charge number counter so we can get a unique googlemap marker title
List<Marker> markers = new List<Marker>();


class CreateCharge extends Action {
  // directions for charge creation
  
  CreateCharge(GMap map, LatLng pos, String title) : super([map, pos, title], _do, _undo);
  
  
  
  static LatLng _do(List args) {
    final map = args[0];
    final pos = args[1];
    final title = args[2];
    
    final oldPos = pos;
    
    var marker = new Marker()
      ..map = map
      ..position = pos
      ..title = title;
    
    markers.add(marker);
    
    // Return the old position as the result, it will be passed to undo.
    return oldPos;
    
  }
 
  
  static void _undo(List args, LatLng oldPos) {

    print('  old Position: ${oldPos}');
    
    // undo the last marker creation
    markers.where((mk) => mk.position.equals(oldPos)).forEach((mk) => mk.map = null);
    markers.removeWhere((mk) => mk.position.equals(oldPos));
    markers.forEach((mk) => print(mk.position.toString()));
    
    
  }
}




void main() {
  
  // Event listeners
  //----------------------------------------------------------------------------------------
  
  map.onClick.listen((e) {
    print('clicked map');
    var markerAdd = new CreateCharge(map, e.latLng, genTitle());
    markerAdd();
  });
  
  
  undoButton.onClick.listen((e) {
    print('undo button');
    undo();
  });
      
  redoButton.onClick.listen((e) {
    print('redo button');
    print(schedule.states.last);
    redo();
  });
  
  schedule.states.listen((state) {
    if (state == Schedule.STATE_IDLE) {
      undoButton.disabled = !schedule.canUndo;
      redoButton.disabled = !schedule.canRedo;
    }
  });
}

