import type { ButtonHTMLAttributes, ReactNode } from "react";
import { cn } from "../../utils/cn";

interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  children: ReactNode;
  icon?: ReactNode;
}

function Button({ children, icon, className, ...props }: ButtonProps) {
  return (
    <button
      className={cn(
        "px-6 py-2.5",
        "bg-primary hover:bg-primary-hover",
        "text-white font-semibold",
        "shadow-secondary",
        "hover:shadow-secondary-hover hover:translate-x-0.5 hover:translate-y-0.5",
        "active:shadow-none active:translate-x-1 active:translate-y-1",
        "transition-all duration-150 ease-in-out",
        "cursor-pointer",
        "flex items-center gap-3",
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
