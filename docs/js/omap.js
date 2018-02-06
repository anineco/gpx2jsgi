// 地理院国土+OpenLayers 2.13.1
function init_omap(param) {
//	var param = {
//		div: 'map_gsimap',
//		lon: 140.672862, lat: 37.864291, zoom: 15,
//		url: 'example/routemap.kml'
//	};
	var proj_3857 = new OpenLayers.Projection('EPSG:3857');
	var proj_4326 =  new OpenLayers.Projection('EPSG:4326');
	var map = new OpenLayers.Map({
		div: param.div,
		projection: proj_3857,
		displayProjection: proj_4326
	});
	var std = new OpenLayers.Layer.XYZ('標準地図', 'http://cyberjapandata.gsi.go.jp/xyz/std/${z}/${x}/${y}.png', {
		attribution: '<a href="http://portal.cyberjapan.jp/help/termsofuse.html" target="_blank">国土地理院</a>',
		maxZoomLevel: 18
	});
	var pale = new OpenLayers.Layer.XYZ('淡色地図', 'http://cyberjapandata.gsi.go.jp/xyz/pale/${z}/${x}/${y}.png', {
		attribution: '<a href="http://portal.cyberjapan.jp/help/termsofuse.html" target="_blank">国土地理院</a>',
		maxZoomLevel: 18
	});
	map.addLayers([std, pale]);
	if (!map.getCenter()) {
		map.setCenter(new OpenLayers.LonLat(param.lon, param.lat).transform(proj_4326, proj_3857), param.zoom);
	}

	map.addControl(new OpenLayers.Control.ScaleLine());
	map.addControl(new OpenLayers.Control.LayerSwitcher());

	var kmlLayer = new OpenLayers.Layer.Vector('GPSデータ', {
		projection: proj_4326,
		strategies: [new OpenLayers.Strategy.Fixed()],
		protocol: new OpenLayers.Protocol.HTTP({
			url: param.url,
			format: new OpenLayers.Format.KML({
				extractStyles: true,
				extractAttributes: true,
				maxDepth: 2
			})
		})
	});
	map.addLayer(kmlLayer);

	kmlLayer.events.on({
		featureselected: onFeatureSelect,
		featureunselected: onFeatureUnselect
	});
	selectControl = new OpenLayers.Control.SelectFeature(kmlLayer);
	map.addControl(selectControl);
	selectControl.activate();

	function onFeatureSelect(event) {
		var feature = event.feature;
		var content = '<h2>' + feature.attributes.name + '</h2>';
		if (feature.attributes.description) {
			content += feature.attributes.description;
		}

		var popup = new OpenLayers.Popup.FramedCloud('chicken',
			feature.geometry.getBounds().getCenterLonLat(),
			new OpenLayers.Size(100,100),
			content, null, true, onPopupClose
		);
		feature.popup = popup;
		map.addPopup(popup);
	}

	function onFeatureUnselect(event) {
		var popup = event.feature.popup;
		if (popup) {
			map.removePopup(popup);
			popup.destroy();
			delete popup;
		}
	}

	function onPopupClose(event) {
		selectControl.unselectAll();
	}
}
