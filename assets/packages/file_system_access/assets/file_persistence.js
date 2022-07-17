//@ts-check

const isSupported =
  "showOpenFilePicker" in window && "FileSystemHandle" in window;
/**
 * @template T
 * @typedef {{
 * put: (v:T, k?:IDBValidKey) => Promise<IDBValidKey>
 * get: (k:IDBValidKey | IDBKeyRange) => Promise<T | undefined>
 * clear: () => Promise
 * getAll: (query?:IDBValidKey | IDBKeyRange, count?:number) => Promise<Array<T>>
 * delete: (k:IDBValidKey | IDBKeyRange) => Promise<undefined>
 * }} PIndexedDB
 */

/**
 * @type {<T>(name: string, objectStore: string) => Promise<PIndexedDB<T>>}
 *  */
const openDB = (name, objectStore) => {
  return new Promise((resolve, reject) => {
    const dbReq = window.indexedDB.open(name, 1);
    dbReq.onupgradeneeded = (e) => {
      dbReq.result.createObjectStore(objectStore, {
        autoIncrement: false,
        keyPath: "id",
      });
    };
    dbReq.onsuccess = (e) => {
      /** @type {<T>(exec: (s:IDBObjectStore) => IDBRequest<T>, mode: IDBTransactionMode) => Promise<T>} */
      const generic = (exec, mode) => {
        return new Promise((resolve, reject) => {
          const tx = dbReq.result.transaction(objectStore, mode);
          const req = exec(tx.objectStore(objectStore));
          req.onsuccess = (e) => tx.commit();
          req.onerror = (e) => tx.abort();

          tx.oncomplete = (e) => resolve(req.result);
          tx.onerror = (e) => reject(e);
          tx.onabort = (e) => reject(e);
        });
      };

      resolve({
        put: (value, key) =>
          generic((store) => store.put(value, key), "readwrite"),
        delete: (query) => generic((store) => store.delete(query), "readwrite"),
        clear: () => generic((store) => store.clear(), "readwrite"),
        get: (id) => generic((store) => store.get(id), "readonly"),
        getAll: (query, count) =>
          generic((store) => store.getAll(query, count), "readonly"),
      });
    };

    dbReq.onerror = (e) => reject(e);
    dbReq.onblocked = (e) => reject(e);
  });
};
/**
 * @typedef {Object} SyncDB
 * @property {Map<number, SavedItem>} allMap
 * @property {Map<FileSystemHandle | string, SavedItem>} allValueMap
 * @property {(v: FileSystemHandle | File) => Promise<SavedItem>} put
 * @property {(id: number) => SavedItem | undefined} get
 * @property {(id: number) => Promise<SavedItem | undefined>} delete
 * @property {() => Array<number>} keys
 * @property {() => Array<SavedItem>} getAll
 *
 **/

/**
 * @typedef {Object} SavedItem
 * @property {number} id
 * @property {FileSystemHandle | SavedFile} value
 * @property {Date} savedDate
 *
 **/

/**
 * @typedef {Object} SavedFile
 * @property {string} name
 * @property {string} type
 * @property {number} lastModified
 * @property {number} size
 * @property {ArrayBuffer} arrayBuffer
 * @property {string} digestSha1Hex
 * @property {string} webkitRelativePath
 *
 **/

/** @type {(value: any) => value is FileSystemHandle} */
const isFileSystemHandle = (value) =>
  isSupported && value instanceof FileSystemHandle;

/** @type {(file: SavedFile) => File} */
const fileFromSavedFile = (file) => {
  const newFile = new File([file.arrayBuffer], file.name, {
    lastModified: file.lastModified,
    type: file.type,
  });
  /** @type {any} */ (newFile).webkitRelativePath = file.webkitRelativePath;

  return newFile;
};

/** @type {(digestSha1Hex: string, file: File | SavedFile) => string} */
const getKeyFromFile = (digestSha1Hex, value) => {
  return [
    digestSha1Hex,
    value.name,
    value.size,
    value.type,
    value.lastModified,
    value.webkitRelativePath,
  ]
    .map((s) => encodeURIComponent(s))
    .join(",");
};

/** @type {(file: FileSystemHandle | SavedFile) => FileSystemHandle | string} */
const getKeyFromSavedValue = (value) => {
  return isFileSystemHandle(value)
    ? value
    : getKeyFromFile(value.digestSha1Hex, value);
};

/** @type {(file: File) => Promise<{digestSha1Hex: string, arrayBuffer: ArrayBuffer, fileKey: string}>} */
const getDigestFromFile = async (file) => {
  const arrayBuffer = await file.arrayBuffer();
  const hashBuffer = await crypto.subtle.digest("SHA-1", arrayBuffer);
  const hashHex = Array.from(new Uint8Array(hashBuffer))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");

  return {
    arrayBuffer: arrayBuffer,
    digestSha1Hex: hashHex,
    fileKey: getKeyFromFile(hashHex, file),
  };
};

/** @type {(dbFuture: Promise<PIndexedDB<SavedItem>>) => Promise<SyncDB>} */
const _dbFunc = (dbFuture) =>
  dbFuture.then((db) =>
    db.getAll().then((all) => {
      // Make maps
      const allMap = new Map(all.map((v) => [v.id, v]));
      const allValueMap = new Map(
        all.map((v) => [getKeyFromSavedValue(v.value), v])
      );
      let maxId = Math.max(...allMap.keys(), 0);

      return {
        allMap,
        allValueMap,
        valuesIterable: () => allMap.values(),
        getAll: () => [...allMap.values()],
        keys: () => [...allMap.keys()],
        get: (id) => allMap.get(id),
        delete: async (id) => {
          const item = allMap.get(id);
          if (!item) return undefined;

          return db.delete(id).then(() => {
            allMap.delete(id);
            allValueMap.delete(getKeyFromSavedValue(item.value));
            return item;
          });
        },
        put: async (v) => {
          if (v instanceof ArrayBuffer) {
            const newV = {
              arrayBuffer: async () => v,
            };
            v = /** @type {File} */ (/** @type {unknown} */ (newV));
          }
          const s = Object.getOwnPropertySymbols(v).find(
            (s) => String(s) === "Symbol(_dartObj)"
          );
          if (s) {
            console.log("Symbol(_dartObj)", s, v);
            v = v[s];
          }
          const arrayBufferInfo = isFileSystemHandle(v)
            ? undefined
            : await getDigestFromFile(v);
          // Retrieve by value
          const _saved = allValueMap.get(
            isFileSystemHandle(v)
              ? v
              : /** @type {string} */ (arrayBufferInfo?.fileKey)
          );
          if (_saved) return _saved;

          // Retrieve by isSameEntry
          for (const [key, value] of allMap) {
            const c = value.value;
            // if ("arrayBuffer" in c && v instanceof File) {
            //   if (
            //     v.name === c.name &&
            //     v.lastModified === c.lastModified &&
            //     v.size === c.size &&
            //     v.type === c.type &&
            //     v.webkitRelativePath === c.webkitRelativePath &&
            //     arrayBufferInfo?.digestSha1Hex === c.digestSha1Hex
            //   ) {
            //     // TODO: should be list of items
            //     return value;
            //   }
            // } else
            if (isFileSystemHandle(c) && isFileSystemHandle(v)) {
              if (
                v.name === c.name &&
                v.kind === c.kind &&
                (await v.isSameEntry(c))
              ) {
                // TODO: should be list of items
                return value;
              }
            }
          }
          // It's not saved, save it
          maxId += 1;
          /** @type {SavedItem} **/
          let item;
          if (isFileSystemHandle(v)) {
            item = { value: v, id: maxId, savedDate: new Date() };
          } else {
            const _arrayBufferInfo =
              /** @type {Awaited<ReturnType<getDigestFromFile>>} */ (
                arrayBufferInfo
              );
            item = {
              id: maxId,
              savedDate: new Date(),
              value: {
                arrayBuffer: _arrayBufferInfo.arrayBuffer,
                digestSha1Hex: _arrayBufferInfo.digestSha1Hex,
                lastModified: v.lastModified,
                type: v.type,
                size: v.size,
                name: v.name,
                webkitRelativePath: v.webkitRelativePath,
              },
            };
          }

          return db.put(item).then((id) => {
            allMap.set(/** @type {number} */ (id), item);
            allValueMap.set(getKeyFromSavedValue(item.value), item);
            return item;
          });
        },
      };
    })
  );

/** @type {Map<string, Promise<SyncDB>>}>} */
const _dbMap = new Map();

/** @type {(obj?:{databaseName?:string, objectStoreName?:string}) => Promise<SyncDB>}>} */
window["getFileSystemAccessFilePersistence"] = (obj) => {
  const databaseName = obj?.databaseName ? obj.databaseName : "FilesDB";
  const objectStoreName = obj?.objectStoreName
    ? obj.objectStoreName
    : "FilesObjectStore";

  const dbKey =
    encodeURIComponent(databaseName) +
    "," +
    encodeURIComponent(objectStoreName);
  let _db = _dbMap.get(dbKey);
  if (_db) return _db;
  _db = _dbFunc(openDB(databaseName, objectStoreName));
  _dbMap.set(dbKey, _db);
  return _db;
};
//   const prev = window.showDirectoryPicker;
//   window.showDirectoryPicker = function () {
//     return prev(arguments).then((v) => {
//       v.saveInIndexedDB = () => {
//         return _db.then((db) =>
//           db.put(v).then((k) => {
//             return k;
//           })
//         );
//       };
//       // v.saveInIndexedDB();

//       // v.deleteFromIndexedDB = () => {
//       //   if (!key) return;
//       //   return _db.then((db) =>
//       //     db.put(v).then((k) => {
//       //       key = k;
//       //       return k;
//       //     })
//       //   );
//       // };
//       return v;
//     });
//   };
