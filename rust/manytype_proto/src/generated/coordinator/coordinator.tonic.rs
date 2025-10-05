// @generated
/// Generated client implementations.
pub mod coordinator_client {
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
    pub struct CoordinatorClient<T> {
        inner: tonic::client::Grpc<T>,
    }
    impl CoordinatorClient<tonic::transport::Channel> {
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
    impl<T> CoordinatorClient<T>
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
        ) -> CoordinatorClient<InterceptedService<T, F>>
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
            CoordinatorClient::new(InterceptedService::new(inner, interceptor))
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
        pub async fn space_sign(
            &mut self,
            request: impl tonic::IntoRequest<super::SpaceSignRequest>,
        ) -> std::result::Result<
            tonic::Response<super::SpaceSignResponse>,
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
                "/coordinator.Coordinator/SpaceSign",
            );
            let mut req = request.into_request();
            req.extensions_mut()
                .insert(GrpcMethod::new("coordinator.Coordinator", "SpaceSign"));
            self.inner.unary(req, path, codec).await
        }
        pub async fn space_status_check(
            &mut self,
            request: impl tonic::IntoRequest<super::SpaceStatusCheckRequest>,
        ) -> std::result::Result<
            tonic::Response<super::SpaceStatusCheckResponse>,
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
                "/coordinator.Coordinator/SpaceStatusCheck",
            );
            let mut req = request.into_request();
            req.extensions_mut()
                .insert(GrpcMethod::new("coordinator.Coordinator", "SpaceStatusCheck"));
            self.inner.unary(req, path, codec).await
        }
        pub async fn space_status_check_many(
            &mut self,
            request: impl tonic::IntoRequest<super::SpaceStatusCheckManyRequest>,
        ) -> std::result::Result<
            tonic::Response<super::SpaceStatusCheckManyResponse>,
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
                "/coordinator.Coordinator/SpaceStatusCheckMany",
            );
            let mut req = request.into_request();
            req.extensions_mut()
                .insert(
                    GrpcMethod::new("coordinator.Coordinator", "SpaceStatusCheckMany"),
                );
            self.inner.unary(req, path, codec).await
        }
        pub async fn space_status_change(
            &mut self,
            request: impl tonic::IntoRequest<super::SpaceStatusChangeRequest>,
        ) -> std::result::Result<
            tonic::Response<super::SpaceStatusChangeResponse>,
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
                "/coordinator.Coordinator/SpaceStatusChange",
            );
            let mut req = request.into_request();
            req.extensions_mut()
                .insert(GrpcMethod::new("coordinator.Coordinator", "SpaceStatusChange"));
            self.inner.unary(req, path, codec).await
        }
        pub async fn space_make_shareable(
            &mut self,
            request: impl tonic::IntoRequest<super::SpaceMakeShareableRequest>,
        ) -> std::result::Result<
            tonic::Response<super::SpaceMakeShareableResponse>,
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
                "/coordinator.Coordinator/SpaceMakeShareable",
            );
            let mut req = request.into_request();
            req.extensions_mut()
                .insert(
                    GrpcMethod::new("coordinator.Coordinator", "SpaceMakeShareable"),
                );
            self.inner.unary(req, path, codec).await
        }
        pub async fn space_make_unshareable(
            &mut self,
            request: impl tonic::IntoRequest<super::SpaceMakeUnshareableRequest>,
        ) -> std::result::Result<
            tonic::Response<super::SpaceMakeUnshareableResponse>,
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
                "/coordinator.Coordinator/SpaceMakeUnshareable",
            );
            let mut req = request.into_request();
            req.extensions_mut()
                .insert(
                    GrpcMethod::new("coordinator.Coordinator", "SpaceMakeUnshareable"),
                );
            self.inner.unary(req, path, codec).await
        }
        pub async fn network_configuration(
            &mut self,
            request: impl tonic::IntoRequest<super::NetworkConfigurationRequest>,
        ) -> std::result::Result<
            tonic::Response<super::NetworkConfigurationResponse>,
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
                "/coordinator.Coordinator/NetworkConfiguration",
            );
            let mut req = request.into_request();
            req.extensions_mut()
                .insert(
                    GrpcMethod::new("coordinator.Coordinator", "NetworkConfiguration"),
                );
            self.inner.unary(req, path, codec).await
        }
        pub async fn deletion_log(
            &mut self,
            request: impl tonic::IntoRequest<super::DeletionLogRequest>,
        ) -> std::result::Result<
            tonic::Response<super::DeletionLogResponse>,
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
                "/coordinator.Coordinator/DeletionLog",
            );
            let mut req = request.into_request();
            req.extensions_mut()
                .insert(GrpcMethod::new("coordinator.Coordinator", "DeletionLog"));
            self.inner.unary(req, path, codec).await
        }
        pub async fn space_delete(
            &mut self,
            request: impl tonic::IntoRequest<super::SpaceDeleteRequest>,
        ) -> std::result::Result<
            tonic::Response<super::SpaceDeleteResponse>,
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
                "/coordinator.Coordinator/SpaceDelete",
            );
            let mut req = request.into_request();
            req.extensions_mut()
                .insert(GrpcMethod::new("coordinator.Coordinator", "SpaceDelete"));
            self.inner.unary(req, path, codec).await
        }
        pub async fn account_delete(
            &mut self,
            request: impl tonic::IntoRequest<super::AccountDeleteRequest>,
        ) -> std::result::Result<
            tonic::Response<super::AccountDeleteResponse>,
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
                "/coordinator.Coordinator/AccountDelete",
            );
            let mut req = request.into_request();
            req.extensions_mut()
                .insert(GrpcMethod::new("coordinator.Coordinator", "AccountDelete"));
            self.inner.unary(req, path, codec).await
        }
        pub async fn account_revert_deletion(
            &mut self,
            request: impl tonic::IntoRequest<super::AccountRevertDeletionRequest>,
        ) -> std::result::Result<
            tonic::Response<super::AccountRevertDeletionResponse>,
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
                "/coordinator.Coordinator/AccountRevertDeletion",
            );
            let mut req = request.into_request();
            req.extensions_mut()
                .insert(
                    GrpcMethod::new("coordinator.Coordinator", "AccountRevertDeletion"),
                );
            self.inner.unary(req, path, codec).await
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
                "/coordinator.Coordinator/AclAddRecord",
            );
            let mut req = request.into_request();
            req.extensions_mut()
                .insert(GrpcMethod::new("coordinator.Coordinator", "AclAddRecord"));
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
                "/coordinator.Coordinator/AclGetRecords",
            );
            let mut req = request.into_request();
            req.extensions_mut()
                .insert(GrpcMethod::new("coordinator.Coordinator", "AclGetRecords"));
            self.inner.unary(req, path, codec).await
        }
        pub async fn account_limits_set(
            &mut self,
            request: impl tonic::IntoRequest<super::AccountLimitsSetRequest>,
        ) -> std::result::Result<
            tonic::Response<super::AccountLimitsSetResponse>,
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
                "/coordinator.Coordinator/AccountLimitsSet",
            );
            let mut req = request.into_request();
            req.extensions_mut()
                .insert(GrpcMethod::new("coordinator.Coordinator", "AccountLimitsSet"));
            self.inner.unary(req, path, codec).await
        }
        pub async fn acl_event_log(
            &mut self,
            request: impl tonic::IntoRequest<super::AclEventLogRequest>,
        ) -> std::result::Result<
            tonic::Response<super::AclEventLogResponse>,
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
                "/coordinator.Coordinator/AclEventLog",
            );
            let mut req = request.into_request();
            req.extensions_mut()
                .insert(GrpcMethod::new("coordinator.Coordinator", "AclEventLog"));
            self.inner.unary(req, path, codec).await
        }
        pub async fn acl_upload_invite(
            &mut self,
            request: impl tonic::IntoRequest<super::AclUploadInviteRequest>,
        ) -> std::result::Result<
            tonic::Response<super::AclUploadInviteResponse>,
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
                "/coordinator.Coordinator/AclUploadInvite",
            );
            let mut req = request.into_request();
            req.extensions_mut()
                .insert(GrpcMethod::new("coordinator.Coordinator", "AclUploadInvite"));
            self.inner.unary(req, path, codec).await
        }
    }
}
/// Generated server implementations.
pub mod coordinator_server {
    #![allow(
        unused_variables,
        dead_code,
        missing_docs,
        clippy::wildcard_imports,
        clippy::let_unit_value,
    )]
    use tonic::codegen::*;
    /// Generated trait containing gRPC methods that should be implemented for use with CoordinatorServer.
    #[async_trait]
    pub trait Coordinator: std::marker::Send + std::marker::Sync + 'static {
        async fn space_sign(
            &self,
            request: tonic::Request<super::SpaceSignRequest>,
        ) -> std::result::Result<
            tonic::Response<super::SpaceSignResponse>,
            tonic::Status,
        >;
        async fn space_status_check(
            &self,
            request: tonic::Request<super::SpaceStatusCheckRequest>,
        ) -> std::result::Result<
            tonic::Response<super::SpaceStatusCheckResponse>,
            tonic::Status,
        >;
        async fn space_status_check_many(
            &self,
            request: tonic::Request<super::SpaceStatusCheckManyRequest>,
        ) -> std::result::Result<
            tonic::Response<super::SpaceStatusCheckManyResponse>,
            tonic::Status,
        >;
        async fn space_status_change(
            &self,
            request: tonic::Request<super::SpaceStatusChangeRequest>,
        ) -> std::result::Result<
            tonic::Response<super::SpaceStatusChangeResponse>,
            tonic::Status,
        >;
        async fn space_make_shareable(
            &self,
            request: tonic::Request<super::SpaceMakeShareableRequest>,
        ) -> std::result::Result<
            tonic::Response<super::SpaceMakeShareableResponse>,
            tonic::Status,
        >;
        async fn space_make_unshareable(
            &self,
            request: tonic::Request<super::SpaceMakeUnshareableRequest>,
        ) -> std::result::Result<
            tonic::Response<super::SpaceMakeUnshareableResponse>,
            tonic::Status,
        >;
        async fn network_configuration(
            &self,
            request: tonic::Request<super::NetworkConfigurationRequest>,
        ) -> std::result::Result<
            tonic::Response<super::NetworkConfigurationResponse>,
            tonic::Status,
        >;
        async fn deletion_log(
            &self,
            request: tonic::Request<super::DeletionLogRequest>,
        ) -> std::result::Result<
            tonic::Response<super::DeletionLogResponse>,
            tonic::Status,
        >;
        async fn space_delete(
            &self,
            request: tonic::Request<super::SpaceDeleteRequest>,
        ) -> std::result::Result<
            tonic::Response<super::SpaceDeleteResponse>,
            tonic::Status,
        >;
        async fn account_delete(
            &self,
            request: tonic::Request<super::AccountDeleteRequest>,
        ) -> std::result::Result<
            tonic::Response<super::AccountDeleteResponse>,
            tonic::Status,
        >;
        async fn account_revert_deletion(
            &self,
            request: tonic::Request<super::AccountRevertDeletionRequest>,
        ) -> std::result::Result<
            tonic::Response<super::AccountRevertDeletionResponse>,
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
        async fn account_limits_set(
            &self,
            request: tonic::Request<super::AccountLimitsSetRequest>,
        ) -> std::result::Result<
            tonic::Response<super::AccountLimitsSetResponse>,
            tonic::Status,
        >;
        async fn acl_event_log(
            &self,
            request: tonic::Request<super::AclEventLogRequest>,
        ) -> std::result::Result<
            tonic::Response<super::AclEventLogResponse>,
            tonic::Status,
        >;
        async fn acl_upload_invite(
            &self,
            request: tonic::Request<super::AclUploadInviteRequest>,
        ) -> std::result::Result<
            tonic::Response<super::AclUploadInviteResponse>,
            tonic::Status,
        >;
    }
    #[derive(Debug)]
    pub struct CoordinatorServer<T> {
        inner: Arc<T>,
        accept_compression_encodings: EnabledCompressionEncodings,
        send_compression_encodings: EnabledCompressionEncodings,
        max_decoding_message_size: Option<usize>,
        max_encoding_message_size: Option<usize>,
    }
    impl<T> CoordinatorServer<T> {
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
    impl<T, B> tonic::codegen::Service<http::Request<B>> for CoordinatorServer<T>
    where
        T: Coordinator,
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
                "/coordinator.Coordinator/SpaceSign" => {
                    #[allow(non_camel_case_types)]
                    struct SpaceSignSvc<T: Coordinator>(pub Arc<T>);
                    impl<
                        T: Coordinator,
                    > tonic::server::UnaryService<super::SpaceSignRequest>
                    for SpaceSignSvc<T> {
                        type Response = super::SpaceSignResponse;
                        type Future = BoxFuture<
                            tonic::Response<Self::Response>,
                            tonic::Status,
                        >;
                        fn call(
                            &mut self,
                            request: tonic::Request<super::SpaceSignRequest>,
                        ) -> Self::Future {
                            let inner = Arc::clone(&self.0);
                            let fut = async move {
                                <T as Coordinator>::space_sign(&inner, request).await
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
                        let method = SpaceSignSvc(inner);
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
                "/coordinator.Coordinator/SpaceStatusCheck" => {
                    #[allow(non_camel_case_types)]
                    struct SpaceStatusCheckSvc<T: Coordinator>(pub Arc<T>);
                    impl<
                        T: Coordinator,
                    > tonic::server::UnaryService<super::SpaceStatusCheckRequest>
                    for SpaceStatusCheckSvc<T> {
                        type Response = super::SpaceStatusCheckResponse;
                        type Future = BoxFuture<
                            tonic::Response<Self::Response>,
                            tonic::Status,
                        >;
                        fn call(
                            &mut self,
                            request: tonic::Request<super::SpaceStatusCheckRequest>,
                        ) -> Self::Future {
                            let inner = Arc::clone(&self.0);
                            let fut = async move {
                                <T as Coordinator>::space_status_check(&inner, request)
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
                        let method = SpaceStatusCheckSvc(inner);
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
                "/coordinator.Coordinator/SpaceStatusCheckMany" => {
                    #[allow(non_camel_case_types)]
                    struct SpaceStatusCheckManySvc<T: Coordinator>(pub Arc<T>);
                    impl<
                        T: Coordinator,
                    > tonic::server::UnaryService<super::SpaceStatusCheckManyRequest>
                    for SpaceStatusCheckManySvc<T> {
                        type Response = super::SpaceStatusCheckManyResponse;
                        type Future = BoxFuture<
                            tonic::Response<Self::Response>,
                            tonic::Status,
                        >;
                        fn call(
                            &mut self,
                            request: tonic::Request<super::SpaceStatusCheckManyRequest>,
                        ) -> Self::Future {
                            let inner = Arc::clone(&self.0);
                            let fut = async move {
                                <T as Coordinator>::space_status_check_many(&inner, request)
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
                        let method = SpaceStatusCheckManySvc(inner);
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
                "/coordinator.Coordinator/SpaceStatusChange" => {
                    #[allow(non_camel_case_types)]
                    struct SpaceStatusChangeSvc<T: Coordinator>(pub Arc<T>);
                    impl<
                        T: Coordinator,
                    > tonic::server::UnaryService<super::SpaceStatusChangeRequest>
                    for SpaceStatusChangeSvc<T> {
                        type Response = super::SpaceStatusChangeResponse;
                        type Future = BoxFuture<
                            tonic::Response<Self::Response>,
                            tonic::Status,
                        >;
                        fn call(
                            &mut self,
                            request: tonic::Request<super::SpaceStatusChangeRequest>,
                        ) -> Self::Future {
                            let inner = Arc::clone(&self.0);
                            let fut = async move {
                                <T as Coordinator>::space_status_change(&inner, request)
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
                        let method = SpaceStatusChangeSvc(inner);
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
                "/coordinator.Coordinator/SpaceMakeShareable" => {
                    #[allow(non_camel_case_types)]
                    struct SpaceMakeShareableSvc<T: Coordinator>(pub Arc<T>);
                    impl<
                        T: Coordinator,
                    > tonic::server::UnaryService<super::SpaceMakeShareableRequest>
                    for SpaceMakeShareableSvc<T> {
                        type Response = super::SpaceMakeShareableResponse;
                        type Future = BoxFuture<
                            tonic::Response<Self::Response>,
                            tonic::Status,
                        >;
                        fn call(
                            &mut self,
                            request: tonic::Request<super::SpaceMakeShareableRequest>,
                        ) -> Self::Future {
                            let inner = Arc::clone(&self.0);
                            let fut = async move {
                                <T as Coordinator>::space_make_shareable(&inner, request)
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
                        let method = SpaceMakeShareableSvc(inner);
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
                "/coordinator.Coordinator/SpaceMakeUnshareable" => {
                    #[allow(non_camel_case_types)]
                    struct SpaceMakeUnshareableSvc<T: Coordinator>(pub Arc<T>);
                    impl<
                        T: Coordinator,
                    > tonic::server::UnaryService<super::SpaceMakeUnshareableRequest>
                    for SpaceMakeUnshareableSvc<T> {
                        type Response = super::SpaceMakeUnshareableResponse;
                        type Future = BoxFuture<
                            tonic::Response<Self::Response>,
                            tonic::Status,
                        >;
                        fn call(
                            &mut self,
                            request: tonic::Request<super::SpaceMakeUnshareableRequest>,
                        ) -> Self::Future {
                            let inner = Arc::clone(&self.0);
                            let fut = async move {
                                <T as Coordinator>::space_make_unshareable(&inner, request)
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
                        let method = SpaceMakeUnshareableSvc(inner);
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
                "/coordinator.Coordinator/NetworkConfiguration" => {
                    #[allow(non_camel_case_types)]
                    struct NetworkConfigurationSvc<T: Coordinator>(pub Arc<T>);
                    impl<
                        T: Coordinator,
                    > tonic::server::UnaryService<super::NetworkConfigurationRequest>
                    for NetworkConfigurationSvc<T> {
                        type Response = super::NetworkConfigurationResponse;
                        type Future = BoxFuture<
                            tonic::Response<Self::Response>,
                            tonic::Status,
                        >;
                        fn call(
                            &mut self,
                            request: tonic::Request<super::NetworkConfigurationRequest>,
                        ) -> Self::Future {
                            let inner = Arc::clone(&self.0);
                            let fut = async move {
                                <T as Coordinator>::network_configuration(&inner, request)
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
                        let method = NetworkConfigurationSvc(inner);
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
                "/coordinator.Coordinator/DeletionLog" => {
                    #[allow(non_camel_case_types)]
                    struct DeletionLogSvc<T: Coordinator>(pub Arc<T>);
                    impl<
                        T: Coordinator,
                    > tonic::server::UnaryService<super::DeletionLogRequest>
                    for DeletionLogSvc<T> {
                        type Response = super::DeletionLogResponse;
                        type Future = BoxFuture<
                            tonic::Response<Self::Response>,
                            tonic::Status,
                        >;
                        fn call(
                            &mut self,
                            request: tonic::Request<super::DeletionLogRequest>,
                        ) -> Self::Future {
                            let inner = Arc::clone(&self.0);
                            let fut = async move {
                                <T as Coordinator>::deletion_log(&inner, request).await
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
                        let method = DeletionLogSvc(inner);
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
                "/coordinator.Coordinator/SpaceDelete" => {
                    #[allow(non_camel_case_types)]
                    struct SpaceDeleteSvc<T: Coordinator>(pub Arc<T>);
                    impl<
                        T: Coordinator,
                    > tonic::server::UnaryService<super::SpaceDeleteRequest>
                    for SpaceDeleteSvc<T> {
                        type Response = super::SpaceDeleteResponse;
                        type Future = BoxFuture<
                            tonic::Response<Self::Response>,
                            tonic::Status,
                        >;
                        fn call(
                            &mut self,
                            request: tonic::Request<super::SpaceDeleteRequest>,
                        ) -> Self::Future {
                            let inner = Arc::clone(&self.0);
                            let fut = async move {
                                <T as Coordinator>::space_delete(&inner, request).await
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
                        let method = SpaceDeleteSvc(inner);
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
                "/coordinator.Coordinator/AccountDelete" => {
                    #[allow(non_camel_case_types)]
                    struct AccountDeleteSvc<T: Coordinator>(pub Arc<T>);
                    impl<
                        T: Coordinator,
                    > tonic::server::UnaryService<super::AccountDeleteRequest>
                    for AccountDeleteSvc<T> {
                        type Response = super::AccountDeleteResponse;
                        type Future = BoxFuture<
                            tonic::Response<Self::Response>,
                            tonic::Status,
                        >;
                        fn call(
                            &mut self,
                            request: tonic::Request<super::AccountDeleteRequest>,
                        ) -> Self::Future {
                            let inner = Arc::clone(&self.0);
                            let fut = async move {
                                <T as Coordinator>::account_delete(&inner, request).await
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
                        let method = AccountDeleteSvc(inner);
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
                "/coordinator.Coordinator/AccountRevertDeletion" => {
                    #[allow(non_camel_case_types)]
                    struct AccountRevertDeletionSvc<T: Coordinator>(pub Arc<T>);
                    impl<
                        T: Coordinator,
                    > tonic::server::UnaryService<super::AccountRevertDeletionRequest>
                    for AccountRevertDeletionSvc<T> {
                        type Response = super::AccountRevertDeletionResponse;
                        type Future = BoxFuture<
                            tonic::Response<Self::Response>,
                            tonic::Status,
                        >;
                        fn call(
                            &mut self,
                            request: tonic::Request<super::AccountRevertDeletionRequest>,
                        ) -> Self::Future {
                            let inner = Arc::clone(&self.0);
                            let fut = async move {
                                <T as Coordinator>::account_revert_deletion(&inner, request)
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
                        let method = AccountRevertDeletionSvc(inner);
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
                "/coordinator.Coordinator/AclAddRecord" => {
                    #[allow(non_camel_case_types)]
                    struct AclAddRecordSvc<T: Coordinator>(pub Arc<T>);
                    impl<
                        T: Coordinator,
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
                                <T as Coordinator>::acl_add_record(&inner, request).await
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
                "/coordinator.Coordinator/AclGetRecords" => {
                    #[allow(non_camel_case_types)]
                    struct AclGetRecordsSvc<T: Coordinator>(pub Arc<T>);
                    impl<
                        T: Coordinator,
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
                                <T as Coordinator>::acl_get_records(&inner, request).await
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
                "/coordinator.Coordinator/AccountLimitsSet" => {
                    #[allow(non_camel_case_types)]
                    struct AccountLimitsSetSvc<T: Coordinator>(pub Arc<T>);
                    impl<
                        T: Coordinator,
                    > tonic::server::UnaryService<super::AccountLimitsSetRequest>
                    for AccountLimitsSetSvc<T> {
                        type Response = super::AccountLimitsSetResponse;
                        type Future = BoxFuture<
                            tonic::Response<Self::Response>,
                            tonic::Status,
                        >;
                        fn call(
                            &mut self,
                            request: tonic::Request<super::AccountLimitsSetRequest>,
                        ) -> Self::Future {
                            let inner = Arc::clone(&self.0);
                            let fut = async move {
                                <T as Coordinator>::account_limits_set(&inner, request)
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
                        let method = AccountLimitsSetSvc(inner);
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
                "/coordinator.Coordinator/AclEventLog" => {
                    #[allow(non_camel_case_types)]
                    struct AclEventLogSvc<T: Coordinator>(pub Arc<T>);
                    impl<
                        T: Coordinator,
                    > tonic::server::UnaryService<super::AclEventLogRequest>
                    for AclEventLogSvc<T> {
                        type Response = super::AclEventLogResponse;
                        type Future = BoxFuture<
                            tonic::Response<Self::Response>,
                            tonic::Status,
                        >;
                        fn call(
                            &mut self,
                            request: tonic::Request<super::AclEventLogRequest>,
                        ) -> Self::Future {
                            let inner = Arc::clone(&self.0);
                            let fut = async move {
                                <T as Coordinator>::acl_event_log(&inner, request).await
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
                        let method = AclEventLogSvc(inner);
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
                "/coordinator.Coordinator/AclUploadInvite" => {
                    #[allow(non_camel_case_types)]
                    struct AclUploadInviteSvc<T: Coordinator>(pub Arc<T>);
                    impl<
                        T: Coordinator,
                    > tonic::server::UnaryService<super::AclUploadInviteRequest>
                    for AclUploadInviteSvc<T> {
                        type Response = super::AclUploadInviteResponse;
                        type Future = BoxFuture<
                            tonic::Response<Self::Response>,
                            tonic::Status,
                        >;
                        fn call(
                            &mut self,
                            request: tonic::Request<super::AclUploadInviteRequest>,
                        ) -> Self::Future {
                            let inner = Arc::clone(&self.0);
                            let fut = async move {
                                <T as Coordinator>::acl_upload_invite(&inner, request).await
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
                        let method = AclUploadInviteSvc(inner);
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
    impl<T> Clone for CoordinatorServer<T> {
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
    pub const SERVICE_NAME: &str = "coordinator.Coordinator";
    impl<T> tonic::server::NamedService for CoordinatorServer<T> {
        const NAME: &'static str = SERVICE_NAME;
    }
}
