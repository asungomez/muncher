import type { ButtonHTMLAttributes, ReactNode } from "react";
import { cn } from "../../utils/cn";

type ButtonVariant = "primary" | "secondary";

interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  children: ReactNode;
  icon?: ReactNode;
  variant?: ButtonVariant;
}

const variantStyles: Record<ButtonVariant, string> = {
  primary: cn(
    "bg-primary hover:bg-primary-hover",
    "text-white",
    "shadow-secondary",
    "hover:shadow-secondary-hover",
  ),
  secondary: cn(
    "bg-secondary hover:bg-secondary-hover",
    "text-dark",
    "shadow-secondary-dark",
    "hover:shadow-secondary-dark-hover",
  ),
};

function Button({
  children,
  icon,
  className,
  variant = "primary",
  ...props
}: ButtonProps) {
  return (
    <button
      className={cn(
        "px-6 py-2.5",
        "font-semibold",
        "hover:translate-x-0.5 hover:translate-y-0.5",
        "active:shadow-none active:translate-x-1 active:translate-y-1",
        "transition-all duration-150 ease-in-out",
        "cursor-pointer",
        "flex items-center gap-3",
        variantStyles[variant],
        className,
      )}
      {...props}
    >
      {icon}
      {children}
    </button>
  );
}

export default Button;
