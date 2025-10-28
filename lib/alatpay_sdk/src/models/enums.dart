enum PaymentChannel {
  web,
  bankTransfer,
  ussd,
  bankDetails,
}

enum PaymentStatus {
  idle,
  loading,
  waitingForOtp,
  waitingForConfirmation,
  confirmationLoading,
  resolvingAccount,
  success,
  failed,
}
