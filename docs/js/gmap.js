// Googleマップ版ルート地図
function init_gmap(param) {
//	var param = {
//		div: 'map_google',
//		lng: 140.672862, lat: 37.864291, zoom: 15,
//		url: 'http://anineco.nyanta.jp/example/routemap.kml'
//	};
	var map = new google.maps.Map(document.getElementById(param.div), {
		zoom: Number(param.zoom),
		center: new google.maps.LatLng(param.lat, param.lng),
		mapTypeId: google.maps.MapTypeId.TERRAIN,
		scaleControl: true
	});
	var ctaLayer = new google.maps.KmlLayer(param.url, {
		preserveViewport: true
	});
	ctaLayer.setMap(map);
}
