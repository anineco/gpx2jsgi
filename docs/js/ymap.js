// Yahoo!地図版ルート地図
function init_ymap(param) {
//	var param = {
//		div: 'map_yahoo',
//		lng: 140.672862, lat: 37.864291, zoom: 16,
//		url: 'http://anineco.github.io/gpx2jsgi/example/Mt_Hayama.kml'
//	};
	var ymap = new Y.Map(param.div);
	ymap.removeLayerSet(Y.LayerSetId.B1); // 地下街
	var topographicLayerSet = new Y.LayerSet('地形図', [new Y.StyleMapLayer('topographic')]);
	ymap.addLayerSet('MyTopographicLayerSet', topographicLayerSet);
	ymap.setConfigure('scrollWheelZoom', true);
	ymap.addControl(new Y.LayerSetControl());
	ymap.addControl(new Y.ZoomControl());
//	ymap.addControl(new Y.SliderZoomControlVertical());
	ymap.addControl(new Y.ScaleControl());
	ymap.drawMap(new Y.LatLng(param.lat, param.lng), param.zoom, 'MyTopographicLayerSet');
	var layer = new Y.GeoXmlLayer(param.url);
	ymap.addLayer(layer);
	layer.execute();
}
