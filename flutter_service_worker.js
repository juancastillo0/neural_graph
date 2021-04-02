'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"manifest.json": "13c922fcaaf6cb8c6be88db9ece0abd7",
"index.html": "57282261273e536e06ca5274873ec4c4",
"/": "57282261273e536e06ca5274873ec4c4",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "6d342eb68f170c97609e9da345464e5e",
"assets/NOTICES": "3afb13d8bd19b3a3546a15cabaec9444",
"assets/fonts/MaterialIcons-Regular.otf": "4e6447691c9509f7acdbf8a931a85ca1",
"assets/AssetManifest.json": "f40047cd935ff96f917c27f76e63daf0",
"assets/google_fonts/NunitoSans-BlackItalic.ttf": "75ec9078a3f7472f3cdee1d312a390a2",
"assets/google_fonts/NunitoSans-Light.ttf": "74d36921be67fb8482bfd7324bd86790",
"assets/google_fonts/OFL.txt": "4e3d9becbf87c0341298fadf87ae4d36",
"assets/google_fonts/NunitoSans-SemiBold.ttf": "bd318b58018198a57723f311627492ac",
"assets/google_fonts/NunitoSans-SemiBoldItalic.ttf": "b16342e303cde3bafe2d8746be885ca2",
"assets/google_fonts/NunitoSans-ExtraBoldItalic.ttf": "2ae455ab84d04fec2d436151e712848f",
"assets/google_fonts/NunitoSans-Black.ttf": "d95152ab5a160491d28b3fce25bf4ff2",
"assets/google_fonts/Cousine-Bold.ttf": "06dae6a1a3247bd76125cfe3b3480557",
"assets/google_fonts/LICENSE.txt": "3b83ef96387f14655fc854ddc3c6bd57",
"assets/google_fonts/NunitoSans-LightItalic.ttf": "d395ff0f45e6b030608de646ec278a35",
"assets/google_fonts/NunitoSans-Bold.ttf": "08e53a516d2ba719d98da46c49b3c369",
"assets/google_fonts/Cousine-Regular.ttf": "64a889644e439ac4806c8e41bc9d1c83",
"assets/google_fonts/Cousine-Italic.ttf": "177a3d2157da07498e805683e8cdaa8d",
"assets/google_fonts/NunitoSans-ExtraLight.ttf": "6aea75496b0ccb484d81a97920d2e64c",
"assets/google_fonts/NunitoSans-ExtraLightItalic.ttf": "cf8d9c6c81866d3bdfc1f08d6ea80d8d",
"assets/google_fonts/Cousine-BoldItalic.ttf": "1038b5579146b28e9e4dc98c8fc5d1d9",
"assets/google_fonts/NunitoSans-ExtraBold.ttf": "505a059580cfbeaccdcb7a489bb67ec9",
"assets/google_fonts/NunitoSans-Italic.ttf": "2d517b40dabe232416b73e3a721dc950",
"assets/google_fonts/NunitoSans-BoldItalic.ttf": "655ce9395fcf8c21f45cfeca5bb280a4",
"assets/google_fonts/NunitoSans-Regular.ttf": "4c8f447011eef80831b45edb1e5971e0",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"main.dart.js": "c91cc0e954e6c55ae7e90b5c736c394d",
"version.json": "82d0a72838d644deec2320d3dda949a4",
"canvaskit_0.25.0/full/canvaskit.js": "d6f5d25a9443bb9507341afc8fd058c5",
"canvaskit_0.25.0/full/canvaskit.wasm": "4238f9424ec50c2b1c6b184b542cada7",
"canvaskit_0.25.0/canvaskit.js": "95226282bb562bd618d4df577b10abc6",
"canvaskit_0.25.0/canvaskit.wasm": "d6a15b04c709e58b6a21f32153173d4d",
"canvaskit_0.25.0/profiling/canvaskit.js": "33f420892f483aec2826bab7d8a339ea",
"canvaskit_0.25.0/profiling/canvaskit.wasm": "8af2a2a16416d9456e2904ac8e1e17f4"
};

// The application shell files that are downloaded before a service worker can
// start.
const CORE = [
  "/",
"main.dart.js",
"index.html",
"assets/NOTICES",
"assets/AssetManifest.json",
"assets/FontManifest.json"];
// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});

// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        return;
      }
      var oldManifest = await manifest.json();
      var origin = (self.location.origin + '/neural_graph');
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});

// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = (self.location.origin + '/neural_graph');
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache.
        return response || fetch(event.request).then((response) => {
          cache.put(event.request, response.clone());
          return response;
        });
      })
    })
  );
});

self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});

// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}

// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
