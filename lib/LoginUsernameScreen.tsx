import React, { useState } from 'react';
import { Badge } from '../components/Badge';

interface LoginUsernameScreenProps {
  onNext: (username: string) => void;
}

export const LoginUsernameScreen: React.FC<LoginUsernameScreenProps> = ({ onNext }) => {
  const [username, setUsername] = useState('');
  const [error, setError] = useState('');

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!username.trim()) {
      setError('Nama user wajib diisi');
      return;
    }
    setError('');
    onNext(username.trim());
  };

  return (
    <div className="min-h-screen bg-[#DCE7F7] flex flex-col p-6">
      <div className="text-[12px] font-bold tracking-wider text-[#5B688A] uppercase">
        MASUK
      </div>

      <div className="flex-1 flex items-center justify-center py-6">
        <div className="w-full max-w-[400px] bg-white rounded-[28px] p-8 shadow-sm">
          <form onSubmit={handleSubmit} className="flex flex-col items-center text-center">
            <Badge />
            <span className="text-[11px] font-bold tracking-[2px] text-[#F5B301] mt-4 uppercase">
              MITRA10
            </span>
            <h1 className="text-[26px] font-bold text-[#172554] mt-1">
              Akurasi
            </h1>
            <p className="text-[13px] text-[#5B688A] leading-relaxed mt-2">
              Masuk dengan nama user kamu untuk<br />mulai misi hari ini
            </p>

            <div className="w-full text-left mt-7">
              <label htmlFor="username-input" className="block text-[12px] text-[#5B688A] mb-1.5 font-medium">
                Nama user
              </label>
              <input
                id="username-input"
                type="text"
                placeholder="nama.user (mis: admin, sahat.sinaga)"
                value={username}
                onChange={(e) => {
                  setUsername(e.target.value);
                  if (error) setError('');
                }}
                className={`w-full px-3.5 py-3 bg-[#F4F7FC] border rounded-xl text-[14px] text-[#172554] focus:outline-none transition-colors ${
                  error ? 'border-[#B3131A]' : 'border-[#DDE4F0] focus:border-[#16225C]'
                }`}
                autoFocus
              />
              {error && (
                <span id="username-error-msg" className="block text-[11.5px] text-[#B3131A] mt-1 font-medium">
                  {error}
                </span>
              )}
            </div>

            <button
              id="btn-login-next"
              type="submit"
              className="w-full mt-5 bg-[#16225C] hover:bg-[#1F2E75] text-white py-3.5 rounded-full text-[15px] font-semibold transition-colors shadow-sm"
            >
              Lanjutkan
            </button>

            <div className="text-[11.5px] text-[#5B688A] leading-relaxed mt-5">
              Dengan melanjutkan, kamu menyetujui{' '}
              <a href="#terms" onClick={(e) => e.preventDefault()} className="text-[#16225C] font-semibold hover:underline">
                Ketentuan Layanan
              </a>{' '}
              dan{' '}
              <a href="#privacy" onClick={(e) => e.preventDefault()} className="text-[#16225C] font-semibold hover:underline">
                Kebijakan Privasi
              </a>.
            </div>
          </form>
        </div>
      </div>
    </div>
  );
};
