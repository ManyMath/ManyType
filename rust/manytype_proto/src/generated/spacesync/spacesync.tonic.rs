// @generated
/// Generated client implementations.
pub mod space_sync_client {
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
    pub struct SpaceSyncClient<T> {
        inner: tonic::client::Grpc<T>,
    }
    impl SpaceSyncClient<tonic::transport::Channel> {
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
    impl<T> SpaceSyncClient<T>
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
        ) -> SpaceSyncClient<InterceptedService<T, F>>
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
            SpaceSyncClient::new(InterceptedService::new(inner, interceptor))
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
        pub async fn head_sync(
            &mut self,
            request: impl tonic::IntoRequest<super::HeadSyncRequest>,
        ) -> std::result::Result<
            tonic::Response<super::HeadSyncResponse>,
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
                "/spacesync.SpaceSync/HeadSync",
            );
            let mut req = request.into_request();
            req.extensions_mut()
                .insert(GrpcMethod::new("spacesync.SpaceSync", "HeadSync"));
            self.inner.unary(req, path, codec).await
        }
        pub async fn store_diff(
            &mut self,
            request: impl tonic::IntoRequest<super::StoreDiffRequest>,
        ) -> std::result::Result<
            tonic::Response<super::StoreDiffResponse>,
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
                "/spacesync.SpaceSync/StoreDiff",
            );
            let mut req = request.into_request();
            req.extensions_mut()
                .insert(GrpcMethod::new("spacesync.SpaceSync", "StoreDiff"));
            self.inner.unary(req, path, codec).await
        }
        pub async fn store_elements(
            &mut self,
            request: impl tonic::IntoStreamingRequest<Message = super::StoreKeyValue>,
        ) -> std::result::Result<
            tonic::Response<tonic::codec::Streaming<super::StoreKeyValue>>,
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
                "/spacesync.SpaceSync/StoreElements",
            );
            let mut req = request.into_streaming_request();
            req.extensions_mut()
                .insert(GrpcMethod::new("spacesync.SpaceSync", "StoreElements"));
            self.inner.streaming(req, path, codec).await
        }
        pub async fn space_push(
            &mut self,
            request: impl tonic::IntoRequest<super::SpacePushRequest>,
        ) -> std::result::Result<
            tonic::Response<super::SpacePushResponse>,
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
                "/spacesync.SpaceSync/SpacePush",
            );
            let mut req = request.into_request();
            req.extensions_mut()
                .insert(GrpcMethod::new("spacesync.SpaceSync", "SpacePush"));
            self.inner.unary(req, path, codec).await
        }
        pub async fn space_pull(
            &mut self,
            request: impl tonic::IntoRequest<super::SpacePullRequest>,
        ) -> std::result::Result<
            tonic::Response<super::SpacePullResponse>,
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
                "/spacesync.SpaceSync/SpacePull",
            );
            let mut req = request.into_request();
            req.extensions_mut()
                .insert(GrpcMethod::new("spacesync.SpaceSync", "SpacePull"));
            self.inner.unary(req, path, codec).await
        }
        pub async fn object_sync_stream(
            &mut self,
            request: impl tonic::IntoStreamingRequest<Message = super::ObjectSyncMessage>,
        ) -> std::result::Result<
            tonic::Response<tonic::codec::Streaming<super::ObjectSyncMessage>>,
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
                "/spacesync.SpaceSync/ObjectSyncStream",
            );
            let mut req = request.into_streaming_request();
            req.extensions_mut()
                .insert(GrpcMethod::new("spacesync.SpaceSync", "ObjectSyncStream"));
            self.inner.streaming(req, path, codec).await
        }
        pub async fn object_sync(
            &mut self,
            request: impl tonic::IntoRequest<super::ObjectSyncMessage>,
        ) -> std::result::Result<
            tonic::Response<super::ObjectSyncMessage>,
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
                "/spacesync.SpaceSync/ObjectSync",
            );
            let mut req = request.into_request();
            req.extensions_mut()
                .insert(GrpcMethod::new("spacesync.SpaceSync", "ObjectSync"));
            self.inner.unary(req, path, codec).await
        }
        pub async fn object_sync_request_stream(
            &mut self,
            request: impl tonic::IntoRequest<super::ObjectSyncMessage>,
        ) -> std::result::Result<
            tonic::Response<tonic::codec::Streaming<super::ObjectSyncMessage>>,
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
                "/spacesync.SpaceSync/ObjectSyncRequestStream",
            );
            let mut req = request.into_request();
            req.extensions_mut()
                .insert(
                    GrpcMethod::new("spacesync.SpaceSync", "ObjectSyncRequestStream"),
                );
            self.inner.server_streaming(req, path, codec).await
        }
        pub async fn acl_add_record(
            &mut self,
            request: impl tonic::IntoRequest<super::AclAddRecordRequest>,
        ) -> std::result::Result<
            tonic::Response<super::AclAddRecordResponse>,
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
                "/spacesync.SpaceSync/AclAddRecord",
            );
            let mut req = request.into_request();
            req.extensions_mut()
                .insert(GrpcMethod::new("spacesync.SpaceSync", "AclAddRecord"));
            self.inner.unary(req, path, codec).await
        }
        pub async fn acl_get_records(
            &mut self,
            request: impl tonic::IntoRequest<super::AclGetRecordsRequest>,
        ) -> std::result::Result<
            tonic::Response<super::AclGetRecordsResponse>,
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
                "/spacesync.SpaceSync/AclGetRecords",
            );
            let mut req = request.into_request();
            req.extensions_mut()
                .insert(GrpcMethod::new("spacesync.SpaceSync", "AclGetRecords"));
            self.inner.unary(req, path, codec).await
        }
    }
}
/// Generated server implementations.
pub mod space_sync_server {
    #![allow(
        unused_variables,
        dead_code,
        missing_docs,
        clippy::wildcard_imports,
        clippy::let_unit_value,
    )]
    use tonic::codegen::*;
    /// Generated trait containing gRPC methods that should be implemented for use with SpaceSyncServer.
    #[async_trait]
    pub trait SpaceSync: std::marker::Send + std::marker::Sync + 'static {
        async fn head_sync(
            &self,
            request: tonic::Request<super::HeadSyncRequest>,
        ) -> std::result::Result<
            tonic::Response<super::HeadSyncResponse>,
            tonic::Status,
        >;
        async fn store_diff(
            &self,
            request: tonic::Request<super::StoreDiffRequest>,
        ) -> std::result::Result<
            tonic::Response<super::StoreDiffResponse>,
            tonic::Status,
        >;
        /// Server streaming response type for the StoreElements method.
        type StoreElementsStream: tonic::codegen::tokio_stream::Stream<
                Item = std::result::Result<super::StoreKeyValue, tonic::Status>,
            >
            + std::marker::Send
            + 'static;
        async fn store_elements(
            &self,
            request: tonic::Request<tonic::Streaming<super::StoreKeyValue>>,
        ) -> std::result::Result<
            tonic::Response<Self::StoreElementsStream>,
            tonic::Status,
        >;
        async fn space_push(
            &self,
            request: tonic::Request<super::SpacePushRequest>,
        ) -> std::result::Result<
            tonic::Response<super::SpacePushResponse>,
            tonic::Status,
        >;
        async fn space_pull(
            &self,
            request: tonic::Request<super::SpacePullRequest>,
        ) -> std::result::Result<
            tonic::Response<super::SpacePullResponse>,
            tonic::Status,
        >;
        /// Server streaming response type for the ObjectSyncStream method.
        type ObjectSyncStreamStream: tonic::codegen::tokio_stream::Stream<
                Item = std::result::Result<super::ObjectSyncMessage, tonic::Status>,
            >
            + std::marker::Send
            + 'static;
        async fn object_sync_stream(
            &self,
            request: tonic::Request<tonic::Streaming<super::ObjectSyncMessage>>,
        ) -> std::result::Result<
            tonic::Response<Self::ObjectSyncStreamStream>,
            tonic::Status,
        >;
        async fn object_sync(
            &self,
            request: tonic::Request<super::ObjectSyncMessage>,
        ) -> std::result::Result<
            tonic::Response<super::ObjectSyncMessage>,
            tonic::Status,
        >;
        /// Server streaming response type for the ObjectSyncRequestStream method.
        type ObjectSyncRequestStreamStream: tonic::codegen::tokio_stream::Stream<
                Item = std::result::Result<super::ObjectSyncMessage, tonic::Status>,
            >
            + std::marker::Send
            + 'static;
        async fn object_sync_request_stream(
            &self,
            request: tonic::Request<super::ObjectSyncMessage>,
        ) -> std::result::Result<
            tonic::Response<Self::ObjectSyncRequestStreamStream>,
            tonic::Status,
        >;
        async fn acl_add_record(
            &self,
            request: tonic::Request<super::AclAddRecordRequest>,
        ) -> std::result::Result<
            tonic::Response<super::AclAddRecordResponse>,
            tonic::Status,
        >;
        async fn acl_get_records(
            &self,
            request: tonic::Request<super::AclGetRecordsRequest>,
        ) -> std::result::Result<
            tonic::Response<super::AclGetRecordsResponse>,
            tonic::Status,
        >;
    }
    #[derive(Debug)]
    pub struct SpaceSyncServer<T> {
        inner: Arc<T>,
        accept_compression_encodings: EnabledCompressionEncodings,
        send_compression_encodings: EnabledCompressionEncodings,
        max_decoding_message_size: Option<usize>,
        max_encoding_message_size: Option<usize>,
    }
    impl<T> SpaceSyncServer<T> {
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
    impl<T, B> tonic::codegen::Service<http::Request<B>> for SpaceSyncServer<T>
    where
        T: SpaceSync,
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
                "/spacesync.SpaceSync/HeadSync" => {
                    #[allow(non_camel_case_types)]
                    struct HeadSyncSvc<T: SpaceSync>(pub Arc<T>);
                    impl<
                        T: SpaceSync,
                    > tonic::server::UnaryService<super::HeadSyncRequest>
                    for HeadSyncSvc<T> {
                        type Response = super::HeadSyncResponse;
                        type Future = BoxFuture<
                            tonic::Response<Self::Response>,
                            tonic::Status,
                        >;
                        fn call(
                            &mut self,
                            request: tonic::Request<super::HeadSyncRequest>,
                        ) -> Self::Future {
                            let inner = Arc::clone(&self.0);
                            let fut = async move {
                                <T as SpaceSync>::head_sync(&inner, request).await
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
                        let method = HeadSyncSvc(inner);
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
                "/spacesync.SpaceSync/StoreDiff" => {
                    #[allow(non_camel_case_types)]
                    struct StoreDiffSvc<T: SpaceSync>(pub Arc<T>);
                    impl<
                        T: SpaceSync,
                    > tonic::server::UnaryService<super::StoreDiffRequest>
                    for StoreDiffSvc<T> {
                        type Response = super::StoreDiffResponse;
                        type Future = BoxFuture<
                            tonic::Response<Self::Response>,
                            tonic::Status,
                        >;
                        fn call(
                            &mut self,
                            request: tonic::Request<super::StoreDiffRequest>,
                        ) -> Self::Future {
                            let inner = Arc::clone(&self.0);
                            let fut = async move {
                                <T as SpaceSync>::store_diff(&inner, request).await
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
                        let method = StoreDiffSvc(inner);
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
                "/spacesync.SpaceSync/StoreElements" => {
                    #[allow(non_camel_case_types)]
                    struct StoreElementsSvc<T: SpaceSync>(pub Arc<T>);
                    impl<
                        T: SpaceSync,
                    > tonic::server::StreamingService<super::StoreKeyValue>
                    for StoreElementsSvc<T> {
                        type Response = super::StoreKeyValue;
                        type ResponseStream = T::StoreElementsStream;
                        type Future = BoxFuture<
                            tonic::Response<Self::ResponseStream>,
                            tonic::Status,
                        >;
                        fn call(
                            &mut self,
                            request: tonic::Request<
                                tonic::Streaming<super::StoreKeyValue>,
                            >,
                        ) -> Self::Future {
                            let inner = Arc::clone(&self.0);
                            let fut = async move {
                                <T as SpaceSync>::store_elements(&inner, request).await
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
                        let method = StoreElementsSvc(inner);
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
                        let res = grpc.streaming(method, req).await;
                        Ok(res)
                    };
                    Box::pin(fut)
                }
                "/spacesync.SpaceSync/SpacePush" => {
                    #[allow(non_camel_case_types)]
                    struct SpacePushSvc<T: SpaceSync>(pub Arc<T>);
                    impl<
                        T: SpaceSync,
                    > tonic::server::UnaryService<super::SpacePushRequest>
                    for SpacePushSvc<T> {
                        type Response = super::SpacePushResponse;
                        type Future = BoxFuture<
                            tonic::Response<Self::Response>,
                            tonic::Status,
                        >;
                        fn call(
                            &mut self,
                            request: tonic::Request<super::SpacePushRequest>,
                        ) -> Self::Future {
                            let inner = Arc::clone(&self.0);
                            let fut = async move {
                                <T as SpaceSync>::space_push(&inner, request).await
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
                        let method = SpacePushSvc(inner);
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
                "/spacesync.SpaceSync/SpacePull" => {
                    #[allow(non_camel_case_types)]
                    struct SpacePullSvc<T: SpaceSync>(pub Arc<T>);
                    impl<
                        T: SpaceSync,
                    > tonic::server::UnaryService<super::SpacePullRequest>
                    for SpacePullSvc<T> {
                        type Response = super::SpacePullResponse;
                        type Future = BoxFuture<
                            tonic::Response<Self::Response>,
                            tonic::Status,
                        >;
                        fn call(
                            &mut self,
                            request: tonic::Request<super::SpacePullRequest>,
                        ) -> Self::Future {
                            let inner = Arc::clone(&self.0);
                            let fut = async move {
                                <T as SpaceSync>::space_pull(&inner, request).await
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
                        let method = SpacePullSvc(inner);
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
                "/spacesync.SpaceSync/ObjectSyncStream" => {
                    #[allow(non_camel_case_types)]
                    struct ObjectSyncStreamSvc<T: SpaceSync>(pub Arc<T>);
                    impl<
                        T: SpaceSync,
                    > tonic::server::StreamingService<super::ObjectSyncMessage>
                    for ObjectSyncStreamSvc<T> {
                        type Response = super::ObjectSyncMessage;
                        type ResponseStream = T::ObjectSyncStreamStream;
                        type Future = BoxFuture<
                            tonic::Response<Self::ResponseStream>,
                            tonic::Status,
                        >;
                        fn call(
                            &mut self,
                            request: tonic::Request<
                                tonic::Streaming<super::ObjectSyncMessage>,
                            >,
                        ) -> Self::Future {
                            let inner = Arc::clone(&self.0);
                            let fut = async move {
                                <T as SpaceSync>::object_sync_stream(&inner, request).await
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
                        let method = ObjectSyncStreamSvc(inner);
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
                        let res = grpc.streaming(method, req).await;
                        Ok(res)
                    };
                    Box::pin(fut)
                }
                "/spacesync.SpaceSync/ObjectSync" => {
                    #[allow(non_camel_case_types)]
                    struct ObjectSyncSvc<T: SpaceSync>(pub Arc<T>);
                    impl<
                        T: SpaceSync,
                    > tonic::server::UnaryService<super::ObjectSyncMessage>
                    for ObjectSyncSvc<T> {
                        type Response = super::ObjectSyncMessage;
                        type Future = BoxFuture<
                            tonic::Response<Self::Response>,
                            tonic::Status,
                        >;
                        fn call(
                            &mut self,
                            request: tonic::Request<super::ObjectSyncMessage>,
                        ) -> Self::Future {
                            let inner = Arc::clone(&self.0);
                            let fut = async move {
                                <T as SpaceSync>::object_sync(&inner, request).await
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
                        let method = ObjectSyncSvc(inner);
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
                "/spacesync.SpaceSync/ObjectSyncRequestStream" => {
                    #[allow(non_camel_case_types)]
                    struct ObjectSyncRequestStreamSvc<T: SpaceSync>(pub Arc<T>);
                    impl<
                        T: SpaceSync,
                    > tonic::server::ServerStreamingService<super::ObjectSyncMessage>
                    for ObjectSyncRequestStreamSvc<T> {
                        type Response = super::ObjectSyncMessage;
                        type ResponseStream = T::ObjectSyncRequestStreamStream;
                        type Future = BoxFuture<
                            tonic::Response<Self::ResponseStream>,
                            tonic::Status,
                        >;
                        fn call(
                            &mut self,
                            request: tonic::Request<super::ObjectSyncMessage>,
                        ) -> Self::Future {
                            let inner = Arc::clone(&self.0);
                            let fut = async move {
                                <T as SpaceSync>::object_sync_request_stream(
                                        &inner,
                                        request,
                                    )
                                    .await
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
                        let method = ObjectSyncRequestStreamSvc(inner);
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
                "/spacesync.SpaceSync/AclAddRecord" => {
                    #[allow(non_camel_case_types)]
                    struct AclAddRecordSvc<T: SpaceSync>(pub Arc<T>);
                    impl<
                        T: SpaceSync,
                    > tonic::server::UnaryService<super::AclAddRecordRequest>
                    for AclAddRecordSvc<T> {
                        type Response = super::AclAddRecordResponse;
                        type Future = BoxFuture<
                            tonic::Response<Self::Response>,
                            tonic::Status,
                        >;
                        fn call(
                            &mut self,
                            request: tonic::Request<super::AclAddRecordRequest>,
                        ) -> Self::Future {
                            let inner = Arc::clone(&self.0);
                            let fut = async move {
                                <T as SpaceSync>::acl_add_record(&inner, request).await
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
                        let method = AclAddRecordSvc(inner);
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
                "/spacesync.SpaceSync/AclGetRecords" => {
                    #[allow(non_camel_case_types)]
                    struct AclGetRecordsSvc<T: SpaceSync>(pub Arc<T>);
                    impl<
                        T: SpaceSync,
                    > tonic::server::UnaryService<super::AclGetRecordsRequest>
                    for AclGetRecordsSvc<T> {
                        type Response = super::AclGetRecordsResponse;
                        type Future = BoxFuture<
                            tonic::Response<Self::Response>,
                            tonic::Status,
                        >;
                        fn call(
                            &mut self,
                            request: tonic::Request<super::AclGetRecordsRequest>,
                        ) -> Self::Future {
                            let inner = Arc::clone(&self.0);
                            let fut = async move {
                                <T as SpaceSync>::acl_get_records(&inner, request).await
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
                        let method = AclGetRecordsSvc(inner);
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
    impl<T> Clone for SpaceSyncServer<T> {
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
    pub const SERVICE_NAME: &str = "spacesync.SpaceSync";
    impl<T> tonic::server::NamedService for SpaceSyncServer<T> {
        const NAME: &'static str = SERVICE_NAME;
    }
}
