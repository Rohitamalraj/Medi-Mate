import React from 'react';
import {
  TouchableOpacity,
  Text,
  StyleSheet,
  View,
  Animated,
} from 'react-native';
import theme from '../theme';

/**
 * Large Voice Button with animated listening indicator
 * Primary interaction point for seniors
 */
const VoiceButton = ({onPress, isListening = false}) => {
  const pulseAnim = React.useRef(new Animated.Value(1)).current;

  React.useEffect(() => {
    if (isListening) {
      // Pulsing animation when listening
      Animated.loop(
        Animated.sequence([
          Animated.timing(pulseAnim, {
            toValue: 1.1,
            duration: 800,
            useNativeDriver: true,
          }),
          Animated.timing(pulseAnim, {
            toValue: 1,
            duration: 800,
            useNativeDriver: true,
          }),
        ]),
      ).start();
    } else {
      pulseAnim.setValue(1);
    }
  }, [isListening, pulseAnim]);

  return (
    <TouchableOpacity
      style={styles.container}
      onPress={onPress}
      activeOpacity={0.8}
      accessibilityRole="button"
      accessibilityLabel="Tap to speak"
      accessibilityHint="Activate voice assistant">
      <Animated.View
        style={[
          styles.button,
          isListening && styles.buttonListening,
          {transform: [{scale: pulseAnim}]},
        ]}>
        {/* Outer glow ring when listening */}
        {isListening && <View style={styles.glowRing} />}

        {/* Microphone icon */}
        <View style={styles.iconContainer}>
          <Text style={styles.micIcon}>🎤</Text>
        </View>

        {/* Button text */}
        <View style={styles.textContainer}>
          <Text style={styles.mainText}>
            {isListening ? 'கேட்கிறேன்...' : 'தொடவும்'}
          </Text>
          <Text style={styles.subText}>
            {isListening ? 'Listening...' : 'TAP TO SPEAK'}
          </Text>
        </View>

        {/* Listening indicator */}
        {isListening && (
          <View style={styles.listeningIndicator}>
            <View style={[styles.dot, styles.dot1]} />
            <View style={[styles.dot, styles.dot2]} />
            <View style={[styles.dot, styles.dot3]} />
          </View>
        )}
      </Animated.View>
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  container: {
    alignItems: 'center',
    marginVertical: theme.spacing.lg,
  },
  button: {
    backgroundColor: theme.colors.primary,
    borderRadius: theme.borderRadius.xlarge,
    paddingVertical: theme.spacing.xl,
    paddingHorizontal: theme.spacing.xxl,
    alignItems: 'center',
    justifyContent: 'center',
    minHeight: 140,
    width: '100%',
    ...theme.shadows.large,
  },
  buttonListening: {
    backgroundColor: theme.colors.accent,
  },
  glowRing: {
    position: 'absolute',
    width: '110%',
    height: '110%',
    borderRadius: theme.borderRadius.xlarge,
    borderWidth: 4,
    borderColor: theme.colors.accent,
    opacity: 0.5,
  },
  iconContainer: {
    marginBottom: theme.spacing.sm,
  },
  micIcon: {
    fontSize: 64,
  },
  textContainer: {
    alignItems: 'center',
  },
  mainText: {
    fontSize: 28,
    fontWeight: theme.typography.bold,
    color: theme.colors.textLight,
    marginBottom: theme.spacing.xs,
  },
  subText: {
    fontSize: 20,
    fontWeight: theme.typography.semibold,
    color: theme.colors.textLight,
    opacity: 0.9,
  },
  listeningIndicator: {
    flexDirection: 'row',
    marginTop: theme.spacing.md,
    gap: theme.spacing.sm,
  },
  dot: {
    width: 12,
    height: 12,
    borderRadius: 6,
    backgroundColor: theme.colors.textLight,
  },
  dot1: {
    opacity: 0.4,
  },
  dot2: {
    opacity: 0.7,
  },
  dot3: {
    opacity: 1,
  },
});

export default VoiceButton;
