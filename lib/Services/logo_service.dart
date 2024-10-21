class LogoService {
  // This method returns the logo URL based on the stock symbol
  String getLogoUrl(String symbol) {
    const logoMap = {
      'AAPL': 'https://logo.clearbit.com/apple.com',
      'GOOGL': 'https://logo.clearbit.com/google.com',
      'MSFT': 'https://logo.clearbit.com/microsoft.com',
    };
    return logoMap[symbol] ?? 'https://via.placeholder.com/50';
  }
}