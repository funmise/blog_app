part of 'init_dependencies.dart';

final serviceLocator = GetIt.instance;

Future<void> intiDependencies() async {
  final supabase = await Supabase.initialize(
    url: AppSecrets.supabaseUrl,
    anonKey: AppSecrets.supabaseAnonKey,
  );

  Hive.defaultDirectory = (await getApplicationCacheDirectory()).path;

  //SupaBase
  serviceLocator
    ..registerLazySingleton(() => supabase.client)
    //core
    ..registerLazySingleton(() => Hive.box(name: 'blogs'))
    ..registerLazySingleton(() => AppUserCubit())
    ..registerFactory(() => InternetConnection())
    ..registerFactory<ConnnectionChecker>(
      () => ConnnectionCheckerImpl(serviceLocator()),
    );

  _initAuth();
  _initBlog();
}

void _initAuth() {
  // Auth state change listener (should add to logger)
  // Supabase.instance.client.auth.onAuthStateChange.listen((data) {
  //   final AuthChangeEvent event = data.event;
  //   //final Session? session = data.session;

  //   debugPrint('Auth Event: $event');
  //   //debugPrint('🧾 Session: ${session?.toJson()}');
  //   //debugPrint('👤 User: ${session?.user.toJson()}');
  // });

  serviceLocator
    // DataSource
    ..registerFactory<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(serviceLocator()),
    )
    ..registerFactory<BlogLocalDataSource>(
      () => BlogLocalDataSourceImpl(serviceLocator()),
    )
    //Repository
    ..registerFactory<AuthRepository>(
      () => AuthRepositoryImpl(serviceLocator(), serviceLocator()),
    )
    //UseCases
    ..registerFactory(() => UserSignUp(serviceLocator()))
    ..registerFactory(() => UserLogin(serviceLocator()))
    ..registerFactory(() => CurrentUser(serviceLocator()))
    //Bloc
    ..registerLazySingleton(
      () => AuthBloc(
        userSignUp: serviceLocator(),
        userLogin: serviceLocator(),
        currentUser: serviceLocator(),
        appUserCubit: serviceLocator(),
      ),
    );
}

void _initBlog() {
  serviceLocator
    // DataSource
    ..registerFactory<BlogRemoteDataSource>(
      () => BlogRemoteDataSourceImpl(serviceLocator()),
    )
    //Repository
    ..registerFactory<BlogRepository>(
      () => BlogRepositoryImpl(
        serviceLocator(),
        serviceLocator(),
        serviceLocator(),
      ),
    )
    //UseCases
    ..registerFactory(() => UploadBlog(serviceLocator()))
    ..registerFactory(() => GetAllBlogs(serviceLocator()))
    //Bloc
    ..registerLazySingleton(
      () =>
          BlogBloc(uploadBlog: serviceLocator(), getAllBlogs: serviceLocator()),
    );
}
