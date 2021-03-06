#!/bin/bash

set -e;

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
$DIR/validate.sh;

node $(npm bin)/check-node-version --node='>=8' --npm='>=5.8';

npm run validate-flat;

cat << EOF | node

    let fs = require('fs');

    const PACKAGE = './package.json';
    const PACKAGE_LOCK = './package-lock.json';

    if (!fs.existsSync(PACKAGE)) {
        throw new Error('Expected package.json to be present');
    }

    if (!fs.existsSync(PACKAGE_LOCK)) {
        throw new Error('Expected package-lock.json to be present');
    }

    let pkg = require(PACKAGE);
    let pkgLock = require(PACKAGE_LOCK);

    let flattenedDependencies = {};
    
    for (let depName of Object.keys(pkgLock.dependencies)) {
        let dep = pkgLock.dependencies[depName];

        if (dep.dev) {
            continue;
        }

        flattenedDependencies[depName] = dep.version;
    }

    pkg.dependencies = flattenedDependencies;
    fs.writeFileSync(PACKAGE, JSON.stringify(pkg, null, 2));

EOF