import Foundation

extension CacheCatalog {
    nonisolated static func packageManagerCacheLocations(home: URL) -> [CleanupLocation] {
        [
            CleanupLocation(
                categoryID: .packages,
                title: "Cargo Registry Cache",
                detail: "Downloaded crate archives recreated by Cargo.",
                url: home.appendingPathComponent(".cargo/registry/cache"),
                kind: .folder,
                minimumProfile: .balanced,
                risk: .low,
                defaultSelected: true,
                recommendedMinimumAgeDays: 7
            ),
            CleanupLocation(
                categoryID: .packages,
                title: "Cargo Git Cache",
                detail: "Cargo git checkout cache recreated by builds.",
                url: home.appendingPathComponent(".cargo/git"),
                kind: .folder,
                minimumProfile: .balanced,
                risk: .low,
                defaultSelected: true,
                recommendedMinimumAgeDays: 14
            ),
            CleanupLocation(
                categoryID: .packages,
                title: "Composer Cache",
                detail: "Composer package cache.",
                url: home.appendingPathComponent(".composer/cache"),
                kind: .folder,
                minimumProfile: .balanced,
                risk: .low,
                defaultSelected: true,
                recommendedMinimumAgeDays: 7
            ),
            CleanupLocation(
                categoryID: .packages,
                title: "Composer Library Cache",
                detail: "Composer cache stored under Library.",
                url: home.appendingPathComponent("Library/Caches/composer"),
                kind: .folder,
                minimumProfile: .balanced,
                risk: .low,
                defaultSelected: true,
                recommendedMinimumAgeDays: 7
            ),
            CleanupLocation(
                categoryID: .packages,
                title: "Deno Cache",
                detail: "Downloaded Deno module cache.",
                url: home.appendingPathComponent("Library/Caches/deno"),
                kind: .folder,
                minimumProfile: .balanced,
                risk: .low,
                defaultSelected: true,
                recommendedMinimumAgeDays: 7
            ),
            CleanupLocation(
                categoryID: .packages,
                title: "node-gyp Cache",
                detail: "Node native build headers and temporary files.",
                url: home.appendingPathComponent(".cache/node-gyp"),
                kind: .folder,
                minimumProfile: .balanced,
                risk: .low,
                defaultSelected: true,
                recommendedMinimumAgeDays: 7
            ),
            CleanupLocation(
                categoryID: .packages,
                title: "node-gyp Headers",
                detail: "Node native build header cache.",
                url: home.appendingPathComponent(".node-gyp"),
                kind: .folder,
                minimumProfile: .balanced,
                risk: .low,
                defaultSelected: true,
                recommendedMinimumAgeDays: 14
            )
        ]
    }

    nonisolated static func developerToolCacheLocations(home: URL) -> [CleanupLocation] {
        var locations: [CleanupLocation] = [
            CleanupLocation(
                categoryID: .developer,
                title: "Bazel Cache",
                detail: "Bazel build cache and external repositories.",
                url: home.appendingPathComponent(".cache/bazel"),
                kind: .folder,
                minimumProfile: .balanced,
                risk: .low,
                defaultSelected: true,
                recommendedMinimumAgeDays: 7
            ),
            CleanupLocation(
                categoryID: .developer,
                title: "Docker Buildx Cache",
                detail: "Docker BuildKit cache metadata, not Docker volumes.",
                url: home.appendingPathComponent(".docker/buildx/cache"),
                kind: .folder,
                minimumProfile: .balanced,
                risk: .low,
                defaultSelected: true,
                recommendedMinimumAgeDays: 7
            ),
            CleanupLocation(
                categoryID: .developer,
                title: "Electron Cache",
                detail: "Downloaded Electron runtime cache.",
                url: home.appendingPathComponent(".cache/electron"),
                kind: .folder,
                minimumProfile: .balanced,
                risk: .low,
                defaultSelected: true,
                recommendedMinimumAgeDays: 7
            ),
            CleanupLocation(
                categoryID: .developer,
                title: "ESLint Cache",
                detail: "ESLint reusable cache files.",
                url: home.appendingPathComponent(".cache/eslint"),
                kind: .folder,
                minimumProfile: .balanced,
                risk: .low,
                defaultSelected: true,
                recommendedMinimumAgeDays: 7
            ),
            CleanupLocation(
                categoryID: .developer,
                title: "Expo Cache",
                detail: "Expo CLI cache data.",
                url: home.appendingPathComponent(".expo/cache"),
                kind: .folder,
                minimumProfile: .balanced,
                risk: .low,
                defaultSelected: true,
                recommendedMinimumAgeDays: 7
            ),
            CleanupLocation(
                categoryID: .developer,
                title: "Mypy Cache",
                detail: "Python type checker cache.",
                url: home.appendingPathComponent(".cache/mypy"),
                kind: .folder,
                minimumProfile: .balanced,
                risk: .low,
                defaultSelected: true,
                recommendedMinimumAgeDays: 7
            ),
            CleanupLocation(
                categoryID: .developer,
                title: "Poetry Cache",
                detail: "Poetry package and virtualenv cache.",
                url: home.appendingPathComponent(".cache/poetry"),
                kind: .folder,
                minimumProfile: .balanced,
                risk: .low,
                defaultSelected: true,
                recommendedMinimumAgeDays: 7
            ),
            CleanupLocation(
                categoryID: .developer,
                title: "Prettier Cache",
                detail: "Prettier reusable cache files.",
                url: home.appendingPathComponent(".cache/prettier"),
                kind: .folder,
                minimumProfile: .balanced,
                risk: .low,
                defaultSelected: true,
                recommendedMinimumAgeDays: 7
            ),
            CleanupLocation(
                categoryID: .developer,
                title: "Pytest Cache",
                detail: "Python test result cache.",
                url: home.appendingPathComponent(".pytest_cache"),
                kind: .folder,
                minimumProfile: .balanced,
                risk: .low,
                defaultSelected: true,
                recommendedMinimumAgeDays: 7
            ),
            CleanupLocation(
                categoryID: .developer,
                title: "Ruff Cache",
                detail: "Ruff lint cache.",
                url: home.appendingPathComponent(".cache/ruff"),
                kind: .folder,
                minimumProfile: .balanced,
                risk: .low,
                defaultSelected: true,
                recommendedMinimumAgeDays: 7
            ),
            CleanupLocation(
                categoryID: .developer,
                title: "Turbo Cache",
                detail: "Turborepo global cache.",
                url: home.appendingPathComponent(".turbo/cache"),
                kind: .folder,
                minimumProfile: .balanced,
                risk: .low,
                defaultSelected: true,
                recommendedMinimumAgeDays: 7
            ),
            CleanupLocation(
                categoryID: .developer,
                title: "TypeScript Cache",
                detail: "TypeScript incremental cache.",
                url: home.appendingPathComponent(".cache/typescript"),
                kind: .folder,
                minimumProfile: .balanced,
                risk: .low,
                defaultSelected: true,
                recommendedMinimumAgeDays: 7
            ),
            CleanupLocation(
                categoryID: .developer,
                title: "Vite Cache",
                detail: "Vite dependency prebundle cache.",
                url: home.appendingPathComponent(".cache/vite"),
                kind: .folder,
                minimumProfile: .balanced,
                risk: .low,
                defaultSelected: true,
                recommendedMinimumAgeDays: 7
            ),
            CleanupLocation(
                categoryID: .developer,
                title: "Vite Project Cache",
                detail: "Vite cache stored in the home cache folder.",
                url: home.appendingPathComponent(".vite/cache"),
                kind: .folder,
                minimumProfile: .balanced,
                risk: .low,
                defaultSelected: true,
                recommendedMinimumAgeDays: 7
            ),
            CleanupLocation(
                categoryID: .developer,
                title: "Webpack Cache",
                detail: "Webpack build cache.",
                url: home.appendingPathComponent(".cache/webpack"),
                kind: .folder,
                minimumProfile: .balanced,
                risk: .low,
                defaultSelected: true,
                recommendedMinimumAgeDays: 7
            )
        ]

        locations.append(contentsOf: folderLocations(
            categoryID: .developer,
            titlePrefix: "Android",
            detailPrefix: "Android build cache",
            root: home.appendingPathComponent(".android"),
            childPaths: ["build-cache", "cache"],
            recommendedMinimumAgeDays: 7
        ))

        locations.append(CleanupLocation(
            categoryID: .developer,
            title: "Jupyter Runtime",
            detail: "Stale Jupyter runtime sockets and kernel state.",
            url: home.appendingPathComponent(".jupyter/runtime"),
            kind: .folder,
            minimumProfile: .balanced,
            risk: .low,
            defaultSelected: true,
            recommendedMinimumAgeDays: 7
        ))

        return locations
    }
}
