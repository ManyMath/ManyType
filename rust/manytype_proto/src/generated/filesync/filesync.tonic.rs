// @generated
/// Generated client implementations.
pub mod file_client {
    #![allow(
        unused_variables,
        dead_code,
        missing_docs,
        clippy::wildcard_imports,
        clippy::let_unit_value,
    )]
    use tonic::codegen::*;
    use tonic::codegen::http::Uri;
    #[derive(Debug, Clone)]
    pub struct FileClient<T> {
        inner: tonic::client::Grpc<T>,
    }
    impl FileClient<tonic::transport::Channel> {
        /// Attempt to create a new client by connecting to a given endpoint.
        pub async fn connect<D>(dst: D) -> Result<Self, tonic::transport::Error>
        where
            D: TryInto<tonic::transport::Endpoint>,
            D::Error: Into<StdError>,
        {
            let conn = tonic::transport::Endpoint::new(dst)?.connect().await?;
            Ok(Self::new(conn))
        }
    }
    impl<T> FileClient<T>
    where
        T: tonic::client::GrpcService<tonic::body::Body>,
        T::Error: Into<StdError>,
        T::ResponseBody: Body<Data = Bytes> + std::marker::Send + 'static,
        <T::ResponseBody as Body>::Error: Into<StdError> + std::marker::Send,
    {
        pub fn new(inner: T) -> Self {
            let inner = tonic::client::Grpc::new(inner);
            Self { inner }
        }
        pub fn with_origin(inner: T, origin: Uri) -> Self {
            let inner = tonic::client::Grpc::with_origin(inner, origin);
            Self { inner }
        }
        pub fn with_interceptor<F>(
            inner: T,
            interceptor: F,
        ) -> FileClient<InterceptedService<T, F>>
        where
            F: tonic::service::Interceptor,
            T::ResponseBody: Default,
            T: tonic::codegen::Service<
                http::Request<tonic::body::Body>,
                Response = http::Response<
                    <T as tonic::client::GrpcService<tonic::body::Body>>::ResponseBody,
                >,
            >,
            <T as tonic::codegen::Service<
                http::Request<tonic::body::Body>,
            >>::Error: Into<StdError> + std::marker::Send + std::marker::Sync,
        {
            FileClient::new(InterceptedService::new(inner, interceptor))
        }
        /// Compress requests with the given encoding.
        ///
        /// This requires the server to support it otherwise it might respond with an
        /// error.
        #[must_use]
        pub fn send_compressed(mut self, encoding: CompressionEncoding) -> Self {
            self.inner = self.inner.send_compressed(encoding);
            self
        }
        /// Enable decompressing responses.
        #[must_use]
        pub fn accept_compressed(mut self, encoding: CompressionEncoding) -> Self {
            self.inner = self.inner.accept_compressed(encoding);
            self
        }
        /// Limits the maximum size of a decoded message.
        ///
        /// Default: `4MB`
        #[must_use]
        pub fn max_decoding_message_size(mut self, limit: usize) -> Self {
            self.inner = self.inner.max_decoding_message_size(limit);
            self
        }
        /// Limits the maximum size of an encoded message.
        ///
        /// Default: `usize::MAX`
        #[must_use]
        pub fn max_encoding_message_size(mut self, limit: usize) -> Self {
            self.inner = self.inner.max_encoding_message_size(limit);
            self
        }
        pub async fn block_get(
            &mut self,
            request: impl tonic::IntoRequest<super::BlockGetRequest>,
        ) -> std::result::Result<
            tonic::Response<super::BlockGetResponse>,
            tonic::Status,
        > {
            self.inner
                .ready()
                .await
                .map_err(|e| {
                    tonic::Status::unknown(
                        format!("Service was not ready: {}", e.into()),
                    )
                })?;
            let codec = tonic_prost::ProstCodec::default();
            let path = http::uri::PathAndQuery::from_static("/filesync.File/BlockGet");
            let mut req = request.into_request();
            req.extensions_mut().insert(GrpcMethod::new("filesync.File", "BlockGet"));
            self.inner.unary(req, path, codec).await
        }
        pub async fn block_push(
            &mut self,
            request: impl tonic::IntoRequest<super::BlockPushRequest>,
        ) -> std::result::Result<tonic::Response<super::Ok>, tonic::Status> {
            self.inner
                .ready()
                .await
                .map_err(|e| {
                    tonic::Status::unknown(
                        format!("Service was not ready: {}", e.into()),
                    )
                })?;
            let codec = tonic_prost::ProstCodec::default();
            let path = http::uri::PathAndQuery::from_static("/filesync.File/BlockPush");
            let mut req = request.into_request();
            req.extensions_mut().insert(GrpcMethod::new("filesync.File", "BlockPush"));
            self.inner.unary(req, path, codec).await
        }
        pub async fn blocks_check(
            &mut self,
            request: impl tonic::IntoRequest<super::BlocksCheckRequest>,
        ) -> std::result::Result<
            tonic::Response<super::BlocksCheckResponse>,
            tonic::Status,
        > {
            self.inner
                .ready()
                .await
                .map_err(|e| {
                    tonic::Status::unknown(
                        format!("Service was not ready: {}", e.into()),
                    )
                })?;
            let codec = tonic_prost::ProstCodec::default();
            let path = http::uri::PathAndQuery::from_static(
                "/filesync.File/BlocksCheck",
            );
            let mut req = request.into_request();
            req.extensions_mut().insert(GrpcMethod::new("filesync.File", "BlocksCheck"));
            self.inner.unary(req, path, codec).await
        }
        pub async fn blocks_bind(
            &mut self,
            request: impl tonic::IntoRequest<super::BlocksBindRequest>,
        ) -> std::result::Result<tonic::Response<super::Ok>, tonic::Status> {
            self.inner
                .ready()
                .await
                .map_err(|e| {
                    tonic::Status::unknown(
                        format!("Service was not ready: {}", e.into()),
                    )
                })?;
            let codec = tonic_prost::ProstCodec::default();
            let path = http::uri::PathAndQuery::from_static("/filesync.File/BlocksBind");
            let mut req = request.into_request();
            req.extensions_mut().insert(GrpcMethod::new("filesync.File", "BlocksBind"));
            self.inner.unary(req, path, codec).await
        }
        pub async fn files_delete(
            &mut self,
            request: impl tonic::IntoRequest<super::FilesDeleteRequest>,
        ) -> std::result::Result<
            tonic::Response<super::FilesDeleteResponse>,
            tonic::Status,
        > {
            self.inner
                .ready()
                .await
                .map_err(|e| {
                    tonic::Status::unknown(
                        format!("Service was not ready: {}", e.into()),
                    )
                })?;
            let codec = tonic_prost::ProstCodec::default();
            let path = http::uri::PathAndQuery::from_static(
                "/filesync.File/FilesDelete",
            );
            let mut req = request.into_request();
            req.extensions_mut().insert(GrpcMethod::new("filesync.File", "FilesDelete"));
            self.inner.unary(req, path, codec).await
        }
        pub async fn files_info(
            &mut self,
            request: impl tonic::IntoRequest<super::FilesInfoRequest>,
        ) -> std::result::Result<
            tonic::Response<super::FilesInfoResponse>,
            tonic::Status,
        > {
            self.inner
                .ready()
                .await
                .map_err(|e| {
                    tonic::Status::unknown(
                        format!("Service was not ready: {}", e.into()),
                    )
                })?;
            let codec = tonic_prost::ProstCodec::default();
            let path = http::uri::PathAndQuery::from_static("/filesync.File/FilesInfo");
            let mut req = request.into_request();
            req.extensions_mut().insert(GrpcMethod::new("filesync.File", "FilesInfo"));
            self.inner.unary(req, path, codec).await
        }
        pub async fn files_get(
            &mut self,
            request: impl tonic::IntoRequest<super::FilesGetRequest>,
        ) -> std::result::Result<
            tonic::Response<tonic::codec::Streaming<super::FilesGetResponse>>,
            tonic::Status,
        > {
            self.inner
                .ready()
                .await
                .map_err(|e| {
                    tonic::Status::unknown(
                        format!("Service was not ready: {}", e.into()),
                    )
                })?;
            let codec = tonic_prost::ProstCodec::default();
            let path = http::uri::PathAndQuery::from_static("/filesync.File/FilesGet");
            let mut req = request.into_request();
            req.extensions_mut().insert(GrpcMethod::new("filesync.File", "FilesGet"));
            self.inner.server_streaming(req, path, codec).await
        }
        pub async fn check(
            &mut self,
            request: impl tonic::IntoRequest<super::CheckRequest>,
        ) -> std::result::Result<tonic::Response<super::CheckResponse>, tonic::Status> {
            self.inner
                .ready()
                .await
                .map_err(|e| {
                    tonic::Status::unknown(
                        format!("Service was not ready: {}", e.into()),
                    )
                })?;
            let codec = tonic_prost::ProstCodec::default();
            let path = http::uri::PathAndQuery::from_static("/filesync.File/Check");
            let mut req = request.into_request();
            req.extensions_mut().insert(GrpcMethod::new("filesync.File", "Check"));
            self.inner.unary(req, path, codec).await
        }
        pub async fn space_info(
            &mut self,
            request: impl tonic::IntoRequest<super::SpaceInfoRequest>,
        ) -> std::result::Result<
            tonic::Response<super::SpaceInfoResponse>,
            tonic::Status,
        > {
            self.inner
                .ready()
                .await
                .map_err(|e| {
                    tonic::Status::unknown(
                        format!("Service was not ready: {}", e.into()),
                    )
                })?;
            let codec = tonic_prost::ProstCodec::default();
            let path = http::uri::PathAndQuery::from_static("/filesync.File/SpaceInfo");
            let mut req = request.into_request();
            req.extensions_mut().insert(GrpcMethod::new("filesync.File", "SpaceInfo"));
            self.inner.unary(req, path, codec).await
        }
        pub async fn account_info(
            &mut self,
            request: impl tonic::IntoRequest<super::AccountInfoRequest>,
        ) -> std::result::Result<
            tonic::Response<super::AccountInfoResponse>,
            tonic::Status,
        > {
            self.inner
                .ready()
                .await
                .map_err(|e| {
                    tonic::Status::unknown(
                        format!("Service was not ready: {}", e.into()),
                    )
                })?;
            let codec = tonic_prost::ProstCodec::default();
            let path = http::uri::PathAndQuery::from_static(
                "/filesync.File/AccountInfo",
            );
            let mut req = request.into_request();
            req.extensions_mut().insert(GrpcMethod::new("filesync.File", "AccountInfo"));
            self.inner.unary(req, path, codec).await
        }
        pub async fn account_limit_set(
            &mut self,
            request: impl tonic::IntoRequest<super::AccountLimitSetRequest>,
        ) -> std::result::Result<tonic::Response<super::Ok>, tonic::Status> {
            self.inner
                .ready()
                .await
                .map_err(|e| {
                    tonic::Status::unknown(
                        format!("Service was not ready: {}", e.into()),
                    )
                })?;
            let codec = tonic_prost::ProstCodec::default();
            let path = http::uri::PathAndQuery::from_static(
                "/filesync.File/AccountLimitSet",
            );
            let mut req = request.into_request();
            req.extensions_mut()
                .insert(GrpcMethod::new("filesync.File", "AccountLimitSet"));
            self.inner.unary(req, path, codec).await
        }
        pub async fn space_limit_set(
            &mut self,
            request: impl tonic::IntoRequest<super::SpaceLimitSetRequest>,
        ) -> std::result::Result<tonic::Response<super::Ok>, tonic::Status> {
            self.inner
                .ready()
                .await
                .map_err(|e| {
                    tonic::Status::unknown(
                        format!("Service was not ready: {}", e.into()),
                    )
                })?;
            let codec = tonic_prost::ProstCodec::default();
            let path = http::uri::PathAndQuery::from_static(
                "/filesync.File/SpaceLimitSet",
            );
            let mut req = request.into_request();
            req.extensions_mut()
                .insert(GrpcMethod::new("filesync.File", "SpaceLimitSet"));
            self.inner.unary(req, path, codec).await
        }
    }
}
/// Generated server implementations.
pub mod file_server {
    #![allow(
        unused_variables,
        dead_code,
        missing_docs,
        clippy::wildcard_imports,
        clippy::let_unit_value,
    )]
    use tonic::codegen::*;
    /// Generated trait containing gRPC methods that should be implemented for use with FileServer.
    #[async_trait]
    pub trait File: std::marker::Send + std::marker::Sync + 'static {
        async fn block_get(
            &self,
            request: tonic::Request<super::BlockGetRequest>,
        ) -> std::result::Result<
            tonic::Response<super::BlockGetResponse>,
            tonic::Status,
        >;
        async fn block_push(
            &self,
            request: tonic::Request<super::BlockPushRequest>,
        ) -> std::result::Result<tonic::Response<super::Ok>, tonic::Status>;
        async fn blocks_check(
            &self,
            request: tonic::Request<super::BlocksCheckRequest>,
        ) -> std::result::Result<
            tonic::Response<super::BlocksCheckResponse>,
            tonic::Status,
        >;
        async fn blocks_bind(
            &self,
            request: tonic::Request<super::BlocksBindRequest>,
        ) -> std::result::Result<tonic::Response<super::Ok>, tonic::Status>;
        async fn files_delete(
            &self,
            request: tonic::Request<super::FilesDeleteRequest>,
        ) -> std::result::Result<
            tonic::Response<super::FilesDeleteResponse>,
            tonic::Status,
        >;
        async fn files_info(
            &self,
            request: tonic::Request<super::FilesInfoRequest>,
        ) -> std::result::Result<
            tonic::Response<super::FilesInfoResponse>,
            tonic::Status,
        >;
        /// Server streaming response type for the FilesGet method.
        type FilesGetStream: tonic::codegen::tokio_stream::Stream<
                Item = std::result::Result<super::FilesGetResponse, tonic::Status>,
            >
            + std::marker::Send
            + 'static;
        async fn files_get(
            &self,
            request: tonic::Request<super::FilesGetRequest>,
        ) -> std::result::Result<tonic::Response<Self::FilesGetStream>, tonic::Status>;
        async fn check(
            &self,
            request: tonic::Request<super::CheckRequest>,
        ) -> std::result::Result<tonic::Response<super::CheckResponse>, tonic::Status>;
        async fn space_info(
            &self,
            request: tonic::Request<super::SpaceInfoRequest>,
        ) -> std::result::Result<
            tonic::Response<super::SpaceInfoResponse>,
            tonic::Status,
        >;
        async fn account_info(
            &self,
            request: tonic::Request<super::AccountInfoRequest>,
        ) -> std::result::Result<
            tonic::Response<super::AccountInfoResponse>,
            tonic::Status,
        >;
        async fn account_limit_set(
            &self,
            request: tonic::Request<super::AccountLimitSetRequest>,
        ) -> std::result::Result<tonic::Response<super::Ok>, tonic::Status>;
        async fn space_limit_set(
            &self,
            request: tonic::Request<super::SpaceLimitSetRequest>,
        ) -> std::result::Result<tonic::Response<super::Ok>, tonic::Status>;
    }
    #[derive(Debug)]
    pub struct FileServer<T> {
        inner: Arc<T>,
        accept_compression_encodings: EnabledCompressionEncodings,
        send_compression_encodings: EnabledCompressionEncodings,
        max_decoding_message_size: Option<usize>,
        max_encoding_message_size: Option<usize>,
    }
    impl<T> FileServer<T> {
        pub fn new(inner: T) -> Self {
            Self::from_arc(Arc::new(inner))
        }
        pub fn from_arc(inner: Arc<T>) -> Self {
            Self {
                inner,
                accept_compression_encodings: Default::default(),
                send_compression_encodings: Default::default(),
                max_decoding_message_size: None,
                max_encoding_message_size: None,
            }
        }
        pub fn with_interceptor<F>(
            inner: T,
            interceptor: F,
        ) -> InterceptedService<Self, F>
        where
            F: tonic::service::Interceptor,
        {
            InterceptedService::new(Self::new(inner), interceptor)
        }
        /// Enable decompressing requests with the given encoding.
        #[must_use]
        pub fn accept_compressed(mut self, encoding: CompressionEncoding) -> Self {
            self.accept_compression_encodings.enable(encoding);
            self
        }
        /// Compress responses with the given encoding, if the client supports it.
        #[must_use]
        pub fn send_compressed(mut self, encoding: CompressionEncoding) -> Self {
            self.send_compression_encodings.enable(encoding);
            self
        }
        /// Limits the maximum size of a decoded message.
        ///
        /// Default: `4MB`
        #[must_use]
        pub fn max_decoding_message_size(mut self, limit: usize) -> Self {
            self.max_decoding_message_size = Some(limit);
            self
        }
        /// Limits the maximum size of an encoded message.
        ///
        /// Default: `usize::MAX`
        #[must_use]
        pub fn max_encoding_message_size(mut self, limit: usize) -> Self {
            self.max_encoding_message_size = Some(limit);
            self
        }
    }
    impl<T, B> tonic::codegen::Service<http::Request<B>> for FileServer<T>
    where
        T: File,
        B: Body + std::marker::Send + 'static,
        B::Error: Into<StdError> + std::marker::Send + 'static,
    {
        type Response = http::Response<tonic::body::Body>;
        type Error = std::convert::Infallible;
        type Future = BoxFuture<Self::Response, Self::Error>;
        fn poll_ready(
            &mut self,
            _cx: &mut Context<'_>,
        ) -> Poll<std::result::Result<(), Self::Error>> {
            Poll::Ready(Ok(()))
        }
        fn call(&mut self, req: http::Request<B>) -> Self::Future {
            match req.uri().path() {
                "/filesync.File/BlockGet" => {
                    #[allow(non_camel_case_types)]
                    struct BlockGetSvc<T: File>(pub Arc<T>);
                    impl<T: File> tonic::server::UnaryService<super::BlockGetRequest>
                    for BlockGetSvc<T> {
                        type Response = super::BlockGetResponse;
                        type Future = BoxFuture<
                            tonic::Response<Self::Response>,
                            tonic::Status,
                        >;
                        fn call(
                            &mut self,
                            request: tonic::Request<super::BlockGetRequest>,
                        ) -> Self::Future {
                            let inner = Arc::clone(&self.0);
                            let fut = async move {
                                <T as File>::block_get(&inner, request).await
                            };
                            Box::pin(fut)
                        }
                    }
                    let accept_compression_encodings = self.accept_compression_encodings;
                    let send_compression_encodings = self.send_compression_encodings;
                    let max_decoding_message_size = self.max_decoding_message_size;
                    let max_encoding_message_size = self.max_encoding_message_size;
                    let inner = self.inner.clone();
                    let fut = async move {
                        let method = BlockGetSvc(inner);
                        let codec = tonic_prost::ProstCodec::default();
                        let mut grpc = tonic::server::Grpc::new(codec)
                            .apply_compression_config(
                                accept_compression_encodings,
                                send_compression_encodings,
                            )
                            .apply_max_message_size_config(
                                max_decoding_message_size,
                                max_encoding_message_size,
                            );
                        let res = grpc.unary(method, req).await;
                        Ok(res)
                    };
                    Box::pin(fut)
                }
                "/filesync.File/BlockPush" => {
                    #[allow(non_camel_case_types)]
                    struct BlockPushSvc<T: File>(pub Arc<T>);
                    impl<T: File> tonic::server::UnaryService<super::BlockPushRequest>
                    for BlockPushSvc<T> {
                        type Response = super::Ok;
                        type Future = BoxFuture<
                            tonic::Response<Self::Response>,
                            tonic::Status,
                        >;
                        fn call(
                            &mut self,
                            request: tonic::Request<super::BlockPushRequest>,
                        ) -> Self::Future {
                            let inner = Arc::clone(&self.0);
                            let fut = async move {
                                <T as File>::block_push(&inner, request).await
                            };
                            Box::pin(fut)
                        }
                    }
                    let accept_compression_encodings = self.accept_compression_encodings;
                    let send_compression_encodings = self.send_compression_encodings;
                    let max_decoding_message_size = self.max_decoding_message_size;
                    let max_encoding_message_size = self.max_encoding_message_size;
                    let inner = self.inner.clone();
                    let fut = async move {
                        let method = BlockPushSvc(inner);
                        let codec = tonic_prost::ProstCodec::default();
                        let mut grpc = tonic::server::Grpc::new(codec)
                            .apply_compression_config(
                                accept_compression_encodings,
                                send_compression_encodings,
                            )
                            .apply_max_message_size_config(
                                max_decoding_message_size,
                                max_encoding_message_size,
                            );
                        let res = grpc.unary(method, req).await;
                        Ok(res)
                    };
                    Box::pin(fut)
                }
                "/filesync.File/BlocksCheck" => {
                    #[allow(non_camel_case_types)]
                    struct BlocksCheckSvc<T: File>(pub Arc<T>);
                    impl<T: File> tonic::server::UnaryService<super::BlocksCheckRequest>
                    for BlocksCheckSvc<T> {
                        type Response = super::BlocksCheckResponse;
                        type Future = BoxFuture<
                            tonic::Response<Self::Response>,
                            tonic::Status,
                        >;
                        fn call(
                            &mut self,
                            request: tonic::Request<super::BlocksCheckRequest>,
                        ) -> Self::Future {
                            let inner = Arc::clone(&self.0);
                            let fut = async move {
                                <T as File>::blocks_check(&inner, request).await
                            };
                            Box::pin(fut)
                        }
                    }
                    let accept_compression_encodings = self.accept_compression_encodings;
                    let send_compression_encodings = self.send_compression_encodings;
                    let max_decoding_message_size = self.max_decoding_message_size;
                    let max_encoding_message_size = self.max_encoding_message_size;
                    let inner = self.inner.clone();
                    let fut = async move {
                        let method = BlocksCheckSvc(inner);
                        let codec = tonic_prost::ProstCodec::default();
                        let mut grpc = tonic::server::Grpc::new(codec)
                            .apply_compression_config(
                                accept_compression_encodings,
                                send_compression_encodings,
                            )
                            .apply_max_message_size_config(
                                max_decoding_message_size,
                                max_encoding_message_size,
                            );
                        let res = grpc.unary(method, req).await;
                        Ok(res)
                    };
                    Box::pin(fut)
                }
                "/filesync.File/BlocksBind" => {
                    #[allow(non_camel_case_types)]
                    struct BlocksBindSvc<T: File>(pub Arc<T>);
                    impl<T: File> tonic::server::UnaryService<super::BlocksBindRequest>
                    for BlocksBindSvc<T> {
                        type Response = super::Ok;
                        type Future = BoxFuture<
                            tonic::Response<Self::Response>,
                            tonic::Status,
                        >;
                        fn call(
                            &mut self,
                            request: tonic::Request<super::BlocksBindRequest>,
                        ) -> Self::Future {
                            let inner = Arc::clone(&self.0);
                            let fut = async move {
                                <T as File>::blocks_bind(&inner, request).await
                            };
                            Box::pin(fut)
                        }
                    }
                    let accept_compression_encodings = self.accept_compression_encodings;
                    let send_compression_encodings = self.send_compression_encodings;
                    let max_decoding_message_size = self.max_decoding_message_size;
                    let max_encoding_message_size = self.max_encoding_message_size;
                    let inner = self.inner.clone();
                    let fut = async move {
                        let method = BlocksBindSvc(inner);
                        let codec = tonic_prost::ProstCodec::default();
                        let mut grpc = tonic::server::Grpc::new(codec)
                            .apply_compression_config(
                                accept_compression_encodings,
                                send_compression_encodings,
                            )
                            .apply_max_message_size_config(
                                max_decoding_message_size,
                                max_encoding_message_size,
                            );
                        let res = grpc.unary(method, req).await;
                        Ok(res)
                    };
                    Box::pin(fut)
                }
                "/filesync.File/FilesDelete" => {
                    #[allow(non_camel_case_types)]
                    struct FilesDeleteSvc<T: File>(pub Arc<T>);
                    impl<T: File> tonic::server::UnaryService<super::FilesDeleteRequest>
                    for FilesDeleteSvc<T> {
                        type Response = super::FilesDeleteResponse;
                        type Future = BoxFuture<
                            tonic::Response<Self::Response>,
                            tonic::Status,
                        >;
                        fn call(
                            &mut self,
                            request: tonic::Request<super::FilesDeleteRequest>,
                        ) -> Self::Future {
                            let inner = Arc::clone(&self.0);
                            let fut = async move {
                                <T as File>::files_delete(&inner, request).await
                            };
                            Box::pin(fut)
                        }
                    }
                    let accept_compression_encodings = self.accept_compression_encodings;
                    let send_compression_encodings = self.send_compression_encodings;
                    let max_decoding_message_size = self.max_decoding_message_size;
                    let max_encoding_message_size = self.max_encoding_message_size;
                    let inner = self.inner.clone();
                    let fut = async move {
                        let method = FilesDeleteSvc(inner);
                        let codec = tonic_prost::ProstCodec::default();
                        let mut grpc = tonic::server::Grpc::new(codec)
                            .apply_compression_config(
                                accept_compression_encodings,
                                send_compression_encodings,
                            )
                            .apply_max_message_size_config(
                                max_decoding_message_size,
                                max_encoding_message_size,
                            );
                        let res = grpc.unary(method, req).await;
                        Ok(res)
                    };
                    Box::pin(fut)
                }
                "/filesync.File/FilesInfo" => {
                    #[allow(non_camel_case_types)]
                    struct FilesInfoSvc<T: File>(pub Arc<T>);
                    impl<T: File> tonic::server::UnaryService<super::FilesInfoRequest>
                    for FilesInfoSvc<T> {
                        type Response = super::FilesInfoResponse;
                        type Future = BoxFuture<
                            tonic::Response<Self::Response>,
                            tonic::Status,
                        >;
                        fn call(
                            &mut self,
                            request: tonic::Request<super::FilesInfoRequest>,
                        ) -> Self::Future {
                            let inner = Arc::clone(&self.0);
                            let fut = async move {
                                <T as File>::files_info(&inner, request).await
                            };
                            Box::pin(fut)
                        }
                    }
                    let accept_compression_encodings = self.accept_compression_encodings;
                    let send_compression_encodings = self.send_compression_encodings;
                    let max_decoding_message_size = self.max_decoding_message_size;
                    let max_encoding_message_size = self.max_encoding_message_size;
                    let inner = self.inner.clone();
                    let fut = async move {
                        let method = FilesInfoSvc(inner);
                        let codec = tonic_prost::ProstCodec::default();
                        let mut grpc = tonic::server::Grpc::new(codec)
                            .apply_compression_config(
                                accept_compression_encodings,
                                send_compression_encodings,
                            )
                            .apply_max_message_size_config(
                                max_decoding_message_size,
                                max_encoding_message_size,
                            );
                        let res = grpc.unary(method, req).await;
                        Ok(res)
                    };
                    Box::pin(fut)
                }
                "/filesync.File/FilesGet" => {
                    #[allow(non_camel_case_types)]
                    struct FilesGetSvc<T: File>(pub Arc<T>);
                    impl<
                        T: File,
                    > tonic::server::ServerStreamingService<super::FilesGetRequest>
                    for FilesGetSvc<T> {
                        type Response = super::FilesGetResponse;
                        type ResponseStream = T::FilesGetStream;
                        type Future = BoxFuture<
                            tonic::Response<Self::ResponseStream>,
                            tonic::Status,
                        >;
                        fn call(
                            &mut self,
                            request: tonic::Request<super::FilesGetRequest>,
                        ) -> Self::Future {
                            let inner = Arc::clone(&self.0);
                            let fut = async move {
                                <T as File>::files_get(&inner, request).await
                            };
                            Box::pin(fut)
                        }
                    }
                    let accept_compression_encodings = self.accept_compression_encodings;
                    let send_compression_encodings = self.send_compression_encodings;
                    let max_decoding_message_size = self.max_decoding_message_size;
                    let max_encoding_message_size = self.max_encoding_message_size;
                    let inner = self.inner.clone();
                    let fut = async move {
                        let method = FilesGetSvc(inner);
                        let codec = tonic_prost::ProstCodec::default();
                        let mut grpc = tonic::server::Grpc::new(codec)
                            .apply_compression_config(
                                accept_compression_encodings,
                                send_compression_encodings,
                            )
                            .apply_max_message_size_config(
                                max_decoding_message_size,
                                max_encoding_message_size,
                            );
                        let res = grpc.server_streaming(method, req).await;
                        Ok(res)
                    };
                    Box::pin(fut)
                }
                "/filesync.File/Check" => {
                    #[allow(non_camel_case_types)]
                    struct CheckSvc<T: File>(pub Arc<T>);
                    impl<T: File> tonic::server::UnaryService<super::CheckRequest>
                    for CheckSvc<T> {
                        type Response = super::CheckResponse;
                        type Future = BoxFuture<
                            tonic::Response<Self::Response>,
                            tonic::Status,
                        >;
                        fn call(
                            &mut self,
                            request: tonic::Request<super::CheckRequest>,
                        ) -> Self::Future {
                            let inner = Arc::clone(&self.0);
                            let fut = async move {
                                <T as File>::check(&inner, request).await
                            };
                            Box::pin(fut)
                        }
                    }
                    let accept_compression_encodings = self.accept_compression_encodings;
                    let send_compression_encodings = self.send_compression_encodings;
                    let max_decoding_message_size = self.max_decoding_message_size;
                    let max_encoding_message_size = self.max_encoding_message_size;
                    let inner = self.inner.clone();
                    let fut = async move {
                        let method = CheckSvc(inner);
                        let codec = tonic_prost::ProstCodec::default();
                        let mut grpc = tonic::server::Grpc::new(codec)
                            .apply_compression_config(
                                accept_compression_encodings,
                                send_compression_encodings,
                            )
                            .apply_max_message_size_config(
                                max_decoding_message_size,
                                max_encoding_message_size,
                            );
                        let res = grpc.unary(method, req).await;
                        Ok(res)
                    };
                    Box::pin(fut)
                }
                "/filesync.File/SpaceInfo" => {
                    #[allow(non_camel_case_types)]
                    struct SpaceInfoSvc<T: File>(pub Arc<T>);
                    impl<T: File> tonic::server::UnaryService<super::SpaceInfoRequest>
                    for SpaceInfoSvc<T> {
                        type Response = super::SpaceInfoResponse;
                        type Future = BoxFuture<
                            tonic::Response<Self::Response>,
                            tonic::Status,
                        >;
                        fn call(
                            &mut self,
                            request: tonic::Request<super::SpaceInfoRequest>,
                        ) -> Self::Future {
                            let inner = Arc::clone(&self.0);
                            let fut = async move {
                                <T as File>::space_info(&inner, request).await
                            };
                            Box::pin(fut)
                        }
                    }
                    let accept_compression_encodings = self.accept_compression_encodings;
                    let send_compression_encodings = self.send_compression_encodings;
                    let max_decoding_message_size = self.max_decoding_message_size;
                    let max_encoding_message_size = self.max_encoding_message_size;
                    let inner = self.inner.clone();
                    let fut = async move {
                        let method = SpaceInfoSvc(inner);
                        let codec = tonic_prost::ProstCodec::default();
                        let mut grpc = tonic::server::Grpc::new(codec)
                            .apply_compression_config(
                                accept_compression_encodings,
                                send_compression_encodings,
                            )
                            .apply_max_message_size_config(
                                max_decoding_message_size,
                                max_encoding_message_size,
                            );
                        let res = grpc.unary(method, req).await;
                        Ok(res)
                    };
                    Box::pin(fut)
                }
                "/filesync.File/AccountInfo" => {
                    #[allow(non_camel_case_types)]
                    struct AccountInfoSvc<T: File>(pub Arc<T>);
                    impl<T: File> tonic::server::UnaryService<super::AccountInfoRequest>
                    for AccountInfoSvc<T> {
                        type Response = super::AccountInfoResponse;
                        type Future = BoxFuture<
                            tonic::Response<Self::Response>,
                            tonic::Status,
                        >;
                        fn call(
                            &mut self,
                            request: tonic::Request<super::AccountInfoRequest>,
                        ) -> Self::Future {
                            let inner = Arc::clone(&self.0);
                            let fut = async move {
                                <T as File>::account_info(&inner, request).await
                            };
                            Box::pin(fut)
                        }
                    }
                    let accept_compression_encodings = self.accept_compression_encodings;
                    let send_compression_encodings = self.send_compression_encodings;
                    let max_decoding_message_size = self.max_decoding_message_size;
                    let max_encoding_message_size = self.max_encoding_message_size;
                    let inner = self.inner.clone();
                    let fut = async move {
                        let method = AccountInfoSvc(inner);
                        let codec = tonic_prost::ProstCodec::default();
                        let mut grpc = tonic::server::Grpc::new(codec)
                            .apply_compression_config(
                                accept_compression_encodings,
                                send_compression_encodings,
                            )
                            .apply_max_message_size_config(
                                max_decoding_message_size,
                                max_encoding_message_size,
                            );
                        let res = grpc.unary(method, req).await;
                        Ok(res)
                    };
                    Box::pin(fut)
                }
                "/filesync.File/AccountLimitSet" => {
                    #[allow(non_camel_case_types)]
                    struct AccountLimitSetSvc<T: File>(pub Arc<T>);
                    impl<
                        T: File,
                    > tonic::server::UnaryService<super::AccountLimitSetRequest>
                    for AccountLimitSetSvc<T> {
                        type Response = super::Ok;
                        type Future = BoxFuture<
                            tonic::Response<Self::Response>,
                            tonic::Status,
                        >;
                        fn call(
                            &mut self,
                            request: tonic::Request<super::AccountLimitSetRequest>,
                        ) -> Self::Future {
                            let inner = Arc::clone(&self.0);
                            let fut = async move {
                                <T as File>::account_limit_set(&inner, request).await
                            };
                            Box::pin(fut)
                        }
                    }
                    let accept_compression_encodings = self.accept_compression_encodings;
                    let send_compression_encodings = self.send_compression_encodings;
                    let max_decoding_message_size = self.max_decoding_message_size;
                    let max_encoding_message_size = self.max_encoding_message_size;
                    let inner = self.inner.clone();
                    let fut = async move {
                        let method = AccountLimitSetSvc(inner);
                        let codec = tonic_prost::ProstCodec::default();
                        let mut grpc = tonic::server::Grpc::new(codec)
                            .apply_compression_config(
                                accept_compression_encodings,
                                send_compression_encodings,
                            )
                            .apply_max_message_size_config(
                                max_decoding_message_size,
                                max_encoding_message_size,
                            );
                        let res = grpc.unary(method, req).await;
                        Ok(res)
                    };
                    Box::pin(fut)
                }
                "/filesync.File/SpaceLimitSet" => {
                    #[allow(non_camel_case_types)]
                    struct SpaceLimitSetSvc<T: File>(pub Arc<T>);
                    impl<
                        T: File,
                    > tonic::server::UnaryService<super::SpaceLimitSetRequest>
                    for SpaceLimitSetSvc<T> {
                        type Response = super::Ok;
                        type Future = BoxFuture<
                            tonic::Response<Self::Response>,
                            tonic::Status,
                        >;
                        fn call(
                            &mut self,
                            request: tonic::Request<super::SpaceLimitSetRequest>,
                        ) -> Self::Future {
                            let inner = Arc::clone(&self.0);
                            let fut = async move {
                                <T as File>::space_limit_set(&inner, request).await
                            };
                            Box::pin(fut)
                        }
                    }
                    let accept_compression_encodings = self.accept_compression_encodings;
                    let send_compression_encodings = self.send_compression_encodings;
                    let max_decoding_message_size = self.max_decoding_message_size;
                    let max_encoding_message_size = self.max_encoding_message_size;
                    let inner = self.inner.clone();
                    let fut = async move {
                        let method = SpaceLimitSetSvc(inner);
                        let codec = tonic_prost::ProstCodec::default();
                        let mut grpc = tonic::server::Grpc::new(codec)
                            .apply_compression_config(
                                accept_compression_encodings,
                                send_compression_encodings,
                            )
                            .apply_max_message_size_config(
                                max_decoding_message_size,
                                max_encoding_message_size,
                            );
                        let res = grpc.unary(method, req).await;
                        Ok(res)
                    };
                    Box::pin(fut)
                }
                _ => {
                    Box::pin(async move {
                        let mut response = http::Response::new(
                            tonic::body::Body::default(),
                        );
                        let headers = response.headers_mut();
                        headers
                            .insert(
                                tonic::Status::GRPC_STATUS,
                                (tonic::Code::Unimplemented as i32).into(),
                            );
                        headers
                            .insert(
                                http::header::CONTENT_TYPE,
                                tonic::metadata::GRPC_CONTENT_TYPE,
                            );
                        Ok(response)
                    })
                }
            }
        }
    }
    impl<T> Clone for FileServer<T> {
        fn clone(&self) -> Self {
            let inner = self.inner.clone();
            Self {
                inner,
                accept_compression_encodings: self.accept_compression_encodings,
                send_compression_encodings: self.send_compression_encodings,
                max_decoding_message_size: self.max_decoding_message_size,
                max_encoding_message_size: self.max_encoding_message_size,
            }
        }
    }
    /// Generated gRPC service name
    pub const SERVICE_NAME: &str = "filesync.File";
    impl<T> tonic::server::NamedService for FileServer<T> {
        const NAME: &'static str = SERVICE_NAME;
    }
}
