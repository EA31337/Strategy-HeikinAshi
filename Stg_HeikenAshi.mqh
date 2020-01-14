//+------------------------------------------------------------------+
//|                  EA31337 - multi-strategy advanced trading robot |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/**
 * @file
 * Implements HeikenAshi strategy based on the Average True Range indicator (Heiken Ashi).
 */

// Includes.
#include <EA31337-classes/Indicators/Indi_HeikenAshi.mqh>
#include <EA31337-classes/Strategy.mqh>

// User input params.
INPUT string __HeikenAshi_Parameters__ = "-- HeikenAshi strategy params --";  // >>> HeikenAshi <<<
INPUT int HeikenAshi_Period = 14;                                             // Averaging period
INPUT ENUM_APPLIED_PRICE HeikenAshi_Applied_Price = PRICE_HIGH;               // Applied price.
INPUT int HeikenAshi_Shift = 0;                     // Shift (relative to the current bar, 0 - default)
INPUT int HeikenAshi_SignalOpenMethod = 0;          // Signal open method (0-1)
INPUT double HeikenAshi_SignalOpenLevel = 0.0004;   // Signal open level (>0.0001)
INPUT int HeikenAshi_SignalCloseMethod = 0;         // Signal close method
INPUT double HeikenAshi_SignalCloseLevel = 0.0004;  // Signal close level (>0.0001)
INPUT int HeikenAshi_PriceLimitMethod = 0;          // Price limit method
INPUT double HeikenAshi_PriceLimitLevel = 0;        // Price limit level
INPUT double HeikenAshi_MaxSpread = 6.0;            // Max spread to trade (pips)

// Struct to define strategy parameters to override.
struct Stg_HeikenAshi_Params : Stg_Params {
  unsigned int HeikenAshi_Period;
  ENUM_APPLIED_PRICE HeikenAshi_Applied_Price;
  int HeikenAshi_Shift;
  int HeikenAshi_SignalOpenMethod;
  double HeikenAshi_SignalOpenLevel;
  int HeikenAshi_SignalCloseMethod;
  double HeikenAshi_SignalCloseLevel;
  int HeikenAshi_PriceLimitMethod;
  double HeikenAshi_PriceLimitLevel;
  double HeikenAshi_MaxSpread;

  // Constructor: Set default param values.
  Stg_HeikenAshi_Params()
      : HeikenAshi_Period(::HeikenAshi_Period),
        HeikenAshi_Applied_Price(::HeikenAshi_Applied_Price),
        HeikenAshi_Shift(::HeikenAshi_Shift),
        HeikenAshi_SignalOpenMethod(::HeikenAshi_SignalOpenMethod),
        HeikenAshi_SignalOpenLevel(::HeikenAshi_SignalOpenLevel),
        HeikenAshi_SignalCloseMethod(::HeikenAshi_SignalCloseMethod),
        HeikenAshi_SignalCloseLevel(::HeikenAshi_SignalCloseLevel),
        HeikenAshi_PriceLimitMethod(::HeikenAshi_PriceLimitMethod),
        HeikenAshi_PriceLimitLevel(::HeikenAshi_PriceLimitLevel),
        HeikenAshi_MaxSpread(::HeikenAshi_MaxSpread) {}
};

// Loads pair specific param values.
#include "sets/EURUSD_H1.h"
#include "sets/EURUSD_H4.h"
#include "sets/EURUSD_M1.h"
#include "sets/EURUSD_M15.h"
#include "sets/EURUSD_M30.h"
#include "sets/EURUSD_M5.h"

class Stg_HeikenAshi : public Strategy {
 public:
  Stg_HeikenAshi(StgParams &_params, string _name) : Strategy(_params, _name) {}

  static Stg_HeikenAshi *Init(ENUM_TIMEFRAMES _tf = NULL, long _magic_no = NULL, ENUM_LOG_LEVEL _log_level = V_INFO) {
    // Initialize strategy initial values.
    Stg_HeikenAshi_Params _params;
    switch (_tf) {
      case PERIOD_M1: {
        Stg_HeikenAshi_EURUSD_M1_Params _new_params;
        _params = _new_params;
      }
      case PERIOD_M5: {
        Stg_HeikenAshi_EURUSD_M5_Params _new_params;
        _params = _new_params;
      }
      case PERIOD_M15: {
        Stg_HeikenAshi_EURUSD_M15_Params _new_params;
        _params = _new_params;
      }
      case PERIOD_M30: {
        Stg_HeikenAshi_EURUSD_M30_Params _new_params;
        _params = _new_params;
      }
      case PERIOD_H1: {
        Stg_HeikenAshi_EURUSD_H1_Params _new_params;
        _params = _new_params;
      }
      case PERIOD_H4: {
        Stg_HeikenAshi_EURUSD_H4_Params _new_params;
        _params = _new_params;
      }
    }
    // Initialize strategy parameters.
    ChartParams cparams(_tf);
    IndicatorParams ha_iparams(10, INDI_HEIKENASHI);
    StgParams sparams(new Trade(_tf, _Symbol), new Indi_HeikenAshi(ha_iparams, cparams), NULL, NULL);
    sparams.logger.SetLevel(_log_level);
    sparams.SetMagicNo(_magic_no);
    sparams.SetSignals(_params.HeikenAshi_SignalOpenMethod, _params.HeikenAshi_SignalOpenMethod,
                       _params.HeikenAshi_SignalCloseMethod, _params.HeikenAshi_SignalCloseMethod);
    sparams.SetMaxSpread(_params.HeikenAshi_MaxSpread);
    // Initialize strategy instance.
    Strategy *_strat = new Stg_HeikenAshi(sparams, "HeikenAshi");
    return _strat;
  }

  /**
   * Update indicator values.
   */
  /*
  bool Update(int tf = EMPTY) {
    // Calculates the Average True Range indicator.
    ratio = tf == 30 ? 1.0 : fmax(HeikenAshi_Period_Ratio, NEAR_ZERO) / tf * 30;
    for (i = 0; i < FINAL_ENUM_INDICATOR_INDEX; i++) {
      ha[index][i][FAST] = iHeikenAshi(symbol, tf, (int)(HeikenAshi_Period_Fast * ratio), i);
      ha[index][i][SLOW] = iHeikenAshi(symbol, tf, (int)(HeikenAshi_Period_Slow * ratio), i);
    }
  }
  */

  /**
   * Check strategy's opening signal.
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method = 0, double _level = 0.0) {
    bool _result = false;
    // UpdateIndicator(S_HeikenAshi, tf);
    // if (signal_method == EMPTY) signal_method = GetStrategySignalOpenMethod(S_HeikenAshi, tf, 0);
    // if (signal_level  == EMPTY) signal_level  = GetStrategySignalLevel(S_HeikenAshi, tf, 0.0);
    switch (_cmd) {
      //   if(iHeikenAshi(NULL,0,12,0)>iHeikenAshi(NULL,0,20,0)) return(0);
      /*
        //6. Average True Range - HeikenAshi
        //Doesn't give independent signals. Is used to define volatility (trend strength).
        //principle: trend must be strengthened. Together with that HeikenAshi grows.
        //Because of the chart form it is inconvenient to analyze rise/fall. Only exceeding of threshold value is
        checked.
        //Flag is 1 when HeikenAshi is above threshold value (i.e. there is a trend), 0 - when HeikenAshi is below
        threshold value, -1 - never. if (iHeikenAshi(NULL,piha,pihau,0)>=minha) {f6=1;}
      */
      case OP_BUY:
        /*
          bool result = HeikenAshi[period][CURR][LOWER] != 0.0 || HeikenAshi[period][PREV][LOWER] != 0.0 ||
          HeikenAshi[period][FAR][LOWER] != 0.0; if ((signal_method &   1) != 0) result &= Open[CURR] > Close[CURR]; if
          ((signal_method &   2) != 0) result &= !HeikenAshi_On_Sell(tf); if ((signal_method &   4) != 0) result &=
          HeikenAshi_On_Buy(fmin(period + 1, M30)); if ((signal_method &   8) != 0) result &= HeikenAshi_On_Buy(M30); if
          ((signal_method &  16) != 0) result &= HeikenAshi[period][FAR][LOWER] != 0.0; if ((signal_method &  32) != 0)
          result &= !HeikenAshi_On_Sell(M30);
          */
        break;
      case OP_SELL:
        /*
          bool result = HeikenAshi[period][CURR][UPPER] != 0.0 || HeikenAshi[period][PREV][UPPER] != 0.0 ||
          HeikenAshi[period][FAR][UPPER] != 0.0; if ((signal_method &   1) != 0) result &= Open[CURR] < Close[CURR]; if
          ((signal_method &   2) != 0) result &= !HeikenAshi_On_Buy(tf); if ((signal_method &   4) != 0) result &=
          HeikenAshi_On_Sell(fmin(period + 1, M30)); if ((signal_method &   8) != 0) result &= HeikenAshi_On_Sell(M30);
          if ((signal_method &  16) != 0) result &= HeikenAshi[period][FAR][UPPER] != 0.0;
          if ((signal_method &  32) != 0) result &= !HeikenAshi_On_Buy(M30);
          */
        break;
    }
    return _result;
  }

  /**
   * Check strategy's closing signal.
   */
  bool SignalClose(ENUM_ORDER_TYPE _cmd, int _method = 0, double _level = 0.0) {
    return SignalOpen(Order::NegateOrderType(_cmd), _method, _level);
  }

  /**
   * Gets price limit value for profit take or stop loss.
   */
  double PriceLimit(ENUM_ORDER_TYPE _cmd, ENUM_STG_PRICE_LIMIT_MODE _mode, int _method = 0, double _level = 0.0) {
    double _trail = _level * Market().GetPipSize();
    int _direction = Order::OrderDirection(_cmd) * (_mode == LIMIT_VALUE_STOP ? -1 : 1);
    double _default_value = Market().GetCloseOffer(_cmd) + _trail * _method * _direction;
    double _result = _default_value;
    switch (_method) {
      case 0: {
        // @todo
      }
    }
    return _result;
  }
};