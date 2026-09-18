import Button from "../Button/Button";

interface StatusMessageProps {
  message: string;
  detail?: string;
  action?: { label: string; onClick: () => void };
}

/** A framed notice standing in for content that is loading, empty or failed. */
function StatusMessage({ message, detail, action }: StatusMessageProps) {
  return (
    <section className="py-8">
      <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="bg-white border-4 border-black shadow-[6px_6px_0px_#000] p-8 flex flex-col items-center gap-4 text-center">
          <p className="text-xl font-bold text-gray-800 font-block">
            {message}
          </p>
          {detail && <p className="text-gray-700">{detail}</p>}
          {action && <Button onClick={action.onClick}>{action.label}</Button>}
        </div>
      </div>
    </section>
  );
}

export default StatusMessage;
